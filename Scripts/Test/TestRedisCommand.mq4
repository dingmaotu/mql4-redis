//+------------------------------------------------------------------+
//|                                                    TestRedis.mq4 |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property version   "1.00"
#property strict

#include <Mt4Redis/RedisContext.mqh>

RedisContext *client=NULL;
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
   client=c;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   RedisReply *r;
   bool hasError = false;

   RedisCommand c;
   c.append("set");
   c.append("y");
   c.append(1);
   r=client.command(c);
   
   hasError = r.isError();
   delete r;

   if(hasError)
     {
      Print("Set y failed.");
      return;
     }
   
   c.clear();

   c.append("bitop");
   c.append("not");
   c.append("z");
   c.append("y");
   r=client.command(c);
   
   hasError = r.isError();
   delete r;

   if(hasError)
     {
      Print("Bitop failed.");
      return;
     }

   r=client.command("get z");

   if(r.isString())
     {
      int v;
      if(r.getStringAsInteger(v))
        {
         int correct = ~1;
         PrintFormat("Bitop result is: %d",v);
         PrintFormat("Correct answer is: %d",correct);
        }
      else
        {
         Print("Failed to get bitop result.");
        }
     }
   else
     {
      Print("Get z failed");
     }
   delete r;
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
