//+------------------------------------------------------------------+
//|                                           TestRedisSubscribe.mq4 |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict

#include <Mt4Redis/RedisPubSub.mqh>

RedisPubSub *client=NULL;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   RedisContext *c=RedisContext::connect("127.0.0.1",6379);
   if(c==NULL)
     {
      return INIT_FAILED;
     }
   client=new RedisPubSub(c);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int n=client.subscribe("tredis");

   if(client.hasError())
     {
      Print("Error occured when subscribing to treids. Prepare to quit");
      return;
     }

   Print("Successfully subscribed to ",n," channel(s).");
   
   string m="";
   do
     {
      m=client.getMessage();
      Print("Receiving: [", m, "]");
     }
   while(!client.hasError() && m!="quit");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(client)!=POINTER_INVALID)
     {
      delete client;
     }
  }
//+------------------------------------------------------------------+
