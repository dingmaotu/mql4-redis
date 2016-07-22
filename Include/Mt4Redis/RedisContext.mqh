//+------------------------------------------------------------------+
//|                                                 RedisContext.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#import "Mt4Redis.dll"
int      mt4RedisConnect(string,int,int,int);
void     mt4RedisDisconnect(int);

int      mt4RedisSetTimeout(int,int,int);
int      mt4RedisEnableKeepAlive(int);

int      mt4RedisError(int);
string   mt4RedisErrorString(int,int&);

int      mt4RedisSimpleCommand(int,const string&);
void     mt4RedisAppendSimpleCommand(int,const string&);
int      mt4RedisComplexCommand(int,int);
void     mt4RedisAppendComplexCommand(int,int);
int      mt4RedisGetReply(int);
#import

#include <stdlib.mqh>

#include "RedisCommon.mqh"
#include "RedisCommand.mqh"
#include "RedisReply.mqh"

//+------------------------------------------------------------------+
//| Redis context: a connection to the redis server                  |
//+------------------------------------------------------------------+
class RedisContext
  {
private:
   int               m_context;
protected:
                     RedisContext(int c);
public:
   static RedisContext *connect(string,int,int seconds=2,int microseconds=0);

   void              disconnect();
   void              enableKeepAlive();
   void              setTimeout(int seconds,int microseconds=0);

   bool              hasError();
   string            getError();

   RedisReply       *command(const string);
   void              appendCommand(const string);
   RedisReply       *command(const RedisCommand&);
   void              appendCommand(const RedisCommand&);
   RedisReply       *getReply();

   int               ref() {return m_context;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisContext::RedisContext(int c)
  {
   m_context=c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisContext *RedisContext::connect(string ip,int port,int seconds,int microseconds)
  {
   int c= mt4RedisConnect(ip,port,seconds,microseconds);
   if(c == 0)
     {
      redisErrorPrint("Redis context can not be allocated!");
      return NULL;
     }
   else
     {
      int err= mt4RedisError(c);
      if(err!=REDIS_OK)
        {
         int buf;
         string res=mt4RedisErrorString(c,buf);
         if(buf>0)
           {
            mt4RedisReleaseStringBuffer(buf);
           }
         redisErrorPrint(res);
         mt4RedisDisconnect(c);
         return NULL;
        }
      else
        {
         Print("Redis context created: #[",c,"]");
         return new RedisContext(c);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedisContext::disconnect(void)
  {
   mt4RedisDisconnect(m_context);
   m_context=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedisContext::enableKeepAlive(void)
  {
   mt4RedisEnableKeepAlive(m_context);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedisContext::setTimeout(int seconds,int microseconds)
  {
   mt4RedisSetTimeout(m_context,seconds,microseconds);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RedisContext::hasError(void)
  {
   int err=mt4RedisError(m_context);
   return err!=REDIS_OK;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string RedisContext::getError(void)
  {
   int buf;
   string res=mt4RedisErrorString(m_context,buf);
   if(buf>0)
     {
      mt4RedisReleaseStringBuffer(buf);
     }
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisReply *RedisContext::command(const string c)
  {
   int r=mt4RedisSimpleCommand(m_context,c);
   if(r == 0)
     {
      return NULL;
     }
   return new RedisReply(r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedisContext::appendCommand(const string c)
  {
   mt4RedisAppendSimpleCommand(m_context,c);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisReply *RedisContext::command(const RedisCommand &c)
  {
   int r=mt4RedisComplexCommand(m_context,c.getRef());
   if(r==0)
     {
      return NULL;
     }
   return new RedisReply(r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedisContext::appendCommand(const RedisCommand &c)
  {
   mt4RedisAppendComplexCommand(m_context,c.getRef());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RedisReply *RedisContext::getReply(void)
  {
   int r= mt4RedisGetReply(m_context);
   if(r == 0)
     {
      return NULL;
     }
   return new RedisReply(r);
  }
//+------------------------------------------------------------------+
