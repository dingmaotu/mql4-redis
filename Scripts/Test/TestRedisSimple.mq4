//+------------------------------------------------------------------+
//|                                             TestRedisPublish.mq4 |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict

#include <Mt4Redis/RedisSimple.mqh>

RedisSimple *client=NULL;
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
   client=new RedisSimple(c);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string value="abcd efg";
   client.setString("examplekey",value);

   if(client.hasError())
     {
      Print("Error occured when setting example key. Prepare to quit");
      return;
     }

   string res=client.getString("examplekey");
   if(StringCompare(res,value)==0)
     {
      Print("Retriving key succeeded.");
     }

   client.setString("examplecounter","1");

   if(client.hasError())
     {
      Print("Error occured when setting example counter. Prepare to quit");
      return;
     }

   long counter=client.increment("examplecounter");

   if(counter==2)
     {
      Print("Increasing counter succeeded.");
     }

   counter=client.decrement("examplecounter");

   if(counter==1)
     {
      Print("Decreasing counter succeeded.");
     }

   counter=client.incrementBy("examplecounter",10);

   if(counter==11)
     {
      Print("Increasing counter by 10 succeeded.");
     }

   counter=client.decrementBy("examplecounter",6);
   
   if(counter==5)
     {
      Print("Decreasing counter by 6 succeeded.");
     }
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
