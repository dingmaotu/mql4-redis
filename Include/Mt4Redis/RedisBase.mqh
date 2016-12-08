//+------------------------------------------------------------------+
//|                                                    RedisBase.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "RedisContext.mqh"
//+------------------------------------------------------------------+
//| Base class for a redis client                                    |
//|                                                                  |
//| Note the protected throw and clear methods:                      |
//| They are ugly but we had to use them as there is no              |
//| exception handling in MQL4                                       |
//+------------------------------------------------------------------+
class RedisBase
  {
private:
   RedisContext     *m_context;
   bool              m_ok;
   string            m_errorMessage;

protected:
   void              throw(const string msg) {m_ok=false; m_errorMessage=msg;}
   void              clear() {m_ok=true;m_errorMessage="";}

   RedisReply       *basicCommand(const string command);

   bool              statusCommand(const string command);
   string            stringCommand(const string command);
   long              integerCommand(const string command);
   int               arrayCommand(const string command,string &array[]);

public:
                     RedisBase(RedisContext *);
   virtual          ~RedisBase();

   //--- error handling
   bool              isOk() const {return m_ok;}
   string            getErrorMessage() const {return m_errorMessage;}

   //--- connection commands
   bool              auth(string password);
   bool              select(int db);
   string            ping(void);
   string            echo(string msg);
   bool              quit(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisBase::RedisBase(RedisContext *c)
   :m_context(c)
  {
   if(m_context==NULL)
     {
      throw("Context is empty.");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisBase::~RedisBase()
  {
   if(CheckPointer(m_context)==POINTER_DYNAMIC)
     {
      m_context.disconnect();
      delete m_context;
     }
  }
//+------------------------------------------------------------------+
//| Issue a simple command and ensure the reply is not error         |
//+------------------------------------------------------------------+
RedisReply *RedisBase::basicCommand(string command)
  {
// Set the client state to ok
// If users of the client decide not to process errors,
// the client should clean the previous command status when they invoke the next command
   clear();
   RedisReply *reply=m_context.command(command);
   if(reply==NULL)
     {
      throw(StringFormat("Failed to get RedisReply: %s",m_context.getError()));
      return NULL;
     }

   if(reply.isError())
     {
      throw(reply.getString());
      delete reply;
      return NULL;
     }

   return reply;
  }
//+------------------------------------------------------------------+
//| Simple commands that return a status or nil                      |
//+------------------------------------------------------------------+
bool RedisBase::statusCommand(string command)
  {
   RedisReply *reply=basicCommand(command);
   if(reply==NULL || reply.isNil() || !reply.isStatus())
     {
      return false;
     }
   else
     {
      delete reply;
      return true;
     }
  }
//+------------------------------------------------------------------+
//| Simple commands that return a string                             |
//+------------------------------------------------------------------+
string RedisBase::stringCommand(string command)
  {
   RedisReply *reply=basicCommand(command);
   if(reply==NULL || reply.isNil() || !reply.isString())
     {
      return NULL;
     }
   else
     {
      string res=reply.getString();
      delete reply;
      return res;
     }
  }
//+------------------------------------------------------------------+
//| Simple commands that return an integer                           |
//+------------------------------------------------------------------+
long RedisBase::integerCommand(string command)
  {
   RedisReply *reply=basicCommand(command);
   if(reply==NULL || reply.isNil() || !reply.isInteger())
     {
      return NULL;
     }
   else
     {
      long res=reply.getInteger();
      delete reply;
      return res;
     }
  }
//+------------------------------------------------------------------+
//| Simple commands that return a string array                       |
//| This method write the result array to its arguments,             |
//| and returns the array size                                       |
//+------------------------------------------------------------------+
int RedisBase::arrayCommand(string command,string &array[])
  {
   RedisReply *reply=basicCommand(command);
   if(reply==NULL || reply.isNil() || !reply.isArray())
     {
      return NULL;
     }
   else
     {
      int res=reply.getSize();
      ArrayResize(array,res);
      for(int i=0; i<res; i++)
        {
         RedisReply*r=reply.getElement(i);
         if(r.isNil())
           {
            array[i]=NULL;
           }
         else
           {
            array[i]=r.getString();
           }
         delete r;
        }
      delete reply;
      return res;
     }
  }
//+------------------------------------------------------------------+
//| Authenticate this client                                         |
//+------------------------------------------------------------------+
bool RedisBase::auth(string password)
  {
   return statusCommand(StringFormat("auth %s", password));
  }
//+------------------------------------------------------------------+
//| Select db number                                                 |
//+------------------------------------------------------------------+
bool RedisBase::select(int db)
  {
   return statusCommand(StringFormat("select %d", db));
  }
//+------------------------------------------------------------------+
//| Ping the server, return "PONG" on success                        |
//+------------------------------------------------------------------+
string RedisBase::ping(void)
  {
   return stringCommand("ping");
  }
//+------------------------------------------------------------------+
//| Echo a message from server                                       |
//+------------------------------------------------------------------+
string RedisBase::echo(string msg)
  {
   return stringCommand(StringFormat("echo %s", msg));
  }
//+------------------------------------------------------------------+
//| Tell the server to disconnect this client after return           |
//| After this command, the context is no longer usable              |
//+------------------------------------------------------------------+
bool RedisBase::quit(void)
  {
   return statusCommand("quit");
  }
//+------------------------------------------------------------------+
