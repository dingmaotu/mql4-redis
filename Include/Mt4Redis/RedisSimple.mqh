//+------------------------------------------------------------------+
//|                                                  RedisSimple.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include "RedisContext.mqh"
//+------------------------------------------------------------------+
//| Simple sample showcasing how to wrap RedisContext low level      |
//| methods to high level redis commands                             |
//|                                                                  |
//| Note those hasError, setError, and clearError methods:           |
//| They are ugly but we had to use them as there is no              |
//| exception handling in MQL4                                       |
//+------------------------------------------------------------------+
class RedisSimple
  {
private:
   RedisContext     *m_context;
   bool              m_hasError;
public:
                     RedisSimple(RedisContext *);
                    ~RedisSimple();

   bool              hasError() const {return m_hasError;}

   void              setError() {m_hasError=true;}
   void              clearError() {m_hasError=false;}

   void              setString(const string key,const string value);
   string            getString(const string key);

   long              increment(const string key);
   long              incrementBy(const string key,int by);
   long              decrement(const string key);
   long              decrementBy(const string key,int by);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisSimple::RedisSimple(RedisContext *c)
  {
   m_context=c;
   m_hasError=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisSimple::~RedisSimple()
  {
   m_context.disconnect();
   delete m_context;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string RedisSimple::getString(const string key)
  {
   clearError();
   RedisReply *reply = m_context.command(StringFormat("get %s", key));
   if(reply == NULL)
     {
      setError();
      return "";
     }
   
   string res = "";

   if(reply.isError())
     {
      redisErrorPrint(reply.getString());
      setError();
     }
   else
     {
      if(reply.isString())
        {
         res = reply.getString();
         delete reply;
         return res;
        }
     }
   delete reply;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedisSimple::setString(const string key,const string value)
  {
   clearError();
   RedisCommand cmd;
   cmd.append("set");
   cmd.append(key);
   cmd.append(value);
   RedisReply *reply=m_context.command(cmd);
   if(reply==NULL)
     {
      setError();
     }

   if(reply.isError())
     {
      redisErrorPrint(reply.getString());
      setError();
     }
   delete reply;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long RedisSimple::increment(const string key)
  {
   clearError();
   RedisReply *reply = m_context.command(StringFormat("incr %s", key));
   if(reply == NULL)
     {
      setError();
     }

   if(reply.isInteger())
     {
      long v = reply.getInteger();
      delete reply;
      return v;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
      delete reply;
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long RedisSimple::incrementBy(const string key,int by)
  {
   clearError();
   RedisReply *reply = m_context.command(StringFormat("incrby %s %d", key, by));
   if(reply == NULL)
     {
      setError();
     }

   if(reply.isInteger())
     {
      long v = reply.getInteger();
      delete reply;
      return v;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
      delete reply;
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long RedisSimple::decrement(const string key)
  {
   clearError();
   RedisReply *reply = m_context.command(StringFormat("decr %s", key));
   if(reply == NULL)
     {
      setError();
     }

   if(reply.isInteger())
     {
      long v = reply.getInteger();
      delete reply;
      return v;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
      delete reply;
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long RedisSimple::decrementBy(const string key,int by)
  {
   clearError();
   RedisReply *reply = m_context.command(StringFormat("decrby %s %d", key, by));
   if(reply == NULL)
     {
      setError();
     }

   if(reply.isInteger())
     {
      long v = reply.getInteger();
      delete reply;
      return v;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
      delete reply;
      return 0;
     }
  }
//+------------------------------------------------------------------+
