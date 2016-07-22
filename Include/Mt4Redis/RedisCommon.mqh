//+------------------------------------------------------------------+
//|                                                  RedisCommon.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#import "Mt4Redis.dll"
void     mt4RedisReleaseStringBuffer(int);
#import

// Generic function return value
#define REDIS_ERR -1

#define REDIS_OK 0

// redisReply types
#define REDIS_REPLY_STRING 1

#define REDIS_REPLY_ARRAY 2

#define REDIS_REPLY_INTEGER 3

#define REDIS_REPLY_NIL 4

#define REDIS_REPLY_STATUS 5

#define REDIS_REPLY_ERROR 6

// Redis error types
#define REDIS_ERR_IO 1

#define REDIS_ERR_EOF 3

#define REDIS_ERR_PROTOCOL 4

#define REDIS_ERR_OOM 5

#define REDIS_ERR_OTHER 2

void redisErrorPrint(string error)
{
   Print("Mt4Redis Error: ", error);
}
//+------------------------------------------------------------------+
