//+------------------------------------------------------------------+
//|                                                  RedisPubSub.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#include "RedisContext.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RedisPubSub
  {
private:
   RedisContext     *m_context;
   bool              m_hasError;
public:
                     RedisPubSub(RedisContext *);
                    ~RedisPubSub();

   bool              hasError() const {return m_hasError;}

   void              setError() {m_hasError=true;}
   void              clearError() {m_hasError=false;}

   int               publish(const string,const string);
   int               subscribe(const string);
   int               unsubscribe(const string);

   int               ppublish(const string,const string);
   int               psubscribe(const string);
   int               punsubscribe(const string);

   string            getMessage();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisPubSub::RedisPubSub(RedisContext *c)
  {
   m_context=c;
   m_hasError=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisPubSub::~RedisPubSub()
  {
   m_context.disconnect();
   delete m_context;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string RedisPubSub::getMessage()
  {
   clearError();
   RedisReply*reply=m_context.getReply();
   if(reply==NULL)
     {
      setError();
      return "";
     }

   string res="";
   if(reply.isArray())
     {
      int s=reply.getSize();
      Print("received array of ",s," elements.");
      RedisReply *rt=NULL;
      for(int i=0; i<s; i++)
        {
         rt=reply.getElement(i);
         Print(i,") ",rt.getString());
         if(s%3==0)
           {
            res=rt.getString();
           }
         delete rt;
        }
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
     }
   delete reply;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RedisPubSub::subscribe(const string channel)
  {
   clearError();
//   int r=mt4RedisSubscribe(m_context.ref(),channel);
   RedisReply *reply=m_context.command(StringFormat("subscribe %s",channel));
   if(reply==NULL)
     {
      setError();
      return 0;
     }

//   RedisReply reply(r);
   int res=0;
   if(reply.isArray())
     {
      int s=reply.getSize();
      Print("received array of ",s," elements.");
      RedisReply *rt=NULL;

      rt=reply.getElement(0);
      Print(0,") ",rt.getString());
      delete rt;

      rt=reply.getElement(1);
      Print(1,") ",rt.getString());
      delete rt;

      rt=reply.getElement(2);
      Print(2,") ",rt.getInteger());
      res=(int)rt.getInteger();
      delete rt;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
     }
   delete reply;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RedisPubSub::unsubscribe(const string channel)
  {
   clearError();
//   int r=mt4RedisUnsubscribe(m_context.ref(),channel);
   RedisReply *reply=m_context.command(StringFormat("unsubscribe %s",channel));
   if(reply==NULL)
     {
      setError();
      return 0;
     }

//   RedisReply reply(r);
   int res=0;
   if(reply.isArray())
     {
      int s=reply.getSize();
      Print("received array of ",s," elements.");
      RedisReply *rt=NULL;
      rt=reply.getElement(0);
      Print(0,") ",rt.getString());
      delete rt;

      rt=reply.getElement(1);
      Print(1,") ",rt.getString());
      delete rt;

      rt=reply.getElement(2);
      Print(2,") ",rt.getInteger());
      res=(int)rt.getInteger();
      delete rt;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
     }
   delete reply;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RedisPubSub::publish(const string channel,const string message)
  {
   clearError();
   RedisCommand cmd;
   cmd.append("publish");
   cmd.append(channel);
   cmd.append(message);
   RedisReply *reply=m_context.command(cmd);
   if(reply==NULL)
     {
      setError();
      return 0;
     }

   if(reply.isInteger())
     {
      int v=(int)reply.getInteger();
      delete reply;
      return v;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      delete reply;
      setError();
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RedisPubSub::psubscribe(const string channel)
  {
   clearError();
   RedisReply *reply=m_context.command(StringFormat("psubscribe %s",channel));
   if(reply==NULL)
     {
      setError();
      return 0;
     }

   int res=0;
   if(reply.isArray())
     {
      int s=reply.getSize();
      Print("received array of ",s," elements.");
      RedisReply *rt=NULL;
      rt=reply.getElement(0);
      Print(0,") ",rt.getString());
      delete rt;

      rt=reply.getElement(1);
      Print(1,") ",rt.getString());
      delete rt;

      rt=reply.getElement(2);
      Print(2,") ",rt.getInteger());
      res=(int)rt.getInteger();
      delete rt;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
     }
   delete reply;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RedisPubSub::punsubscribe(const string channel)
  {
   clearError();
   RedisReply *reply=m_context.command(StringFormat("punsubscribe %s",channel));
   if(reply==NULL)
     {
      setError();
      return 0;
     }

   int res=0;
   if(reply.isArray())
     {
      int s=reply.getSize();
      Print("received array of ",s," elements.");
      RedisReply *rt=NULL;
      rt=reply.getElement(0);
      Print(0,") ",rt.getString());
      delete rt;

      rt=reply.getElement(1);
      Print(1,") ",rt.getString());
      delete rt;

      rt=reply.getElement(2);
      Print(2,") ",rt.getInteger());
      res=(int)rt.getInteger();
      delete rt;
     }
   else
     {
      if(reply.isError())
        {
         redisErrorPrint(reply.getString());
        }
      setError();
     }
   delete reply;
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RedisPubSub::ppublish(const string channel,const string message)
  {
   clearError();
   RedisCommand cmd;
   cmd.append("publish");
   cmd.append(channel);
   cmd.append(message);
   RedisReply *reply=m_context.command(cmd);
   if(reply==NULL)
     {
      setError();
      return 0;
     }

   if(reply.isInteger())
     {
      int v = (int)reply.getInteger();
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
