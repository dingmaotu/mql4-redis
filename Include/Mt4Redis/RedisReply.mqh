//+------------------------------------------------------------------+
//|                                                   RedisReply.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict

#import "Mt4Redis.dll"
int      mt4RedisReplyGetType(int);

long     mt4RedisReplyGetInteger(int);

int      mt4RedisReplyGetNumberOfElements(int);
int      mt4RedisReplyGetElement(int,int);

int      mt4RedisReplyGetLength(int);
string   mt4RedisReplyGetString(int,int&);
int      mt4RedisReplyGetBytes(int,char &[],int);
int      mt4RedisReplyGetBytes(int,int&,int);

void     mt4RedisReplyFree(int);
#import

#include "RedisCommon.mqh"
//+------------------------------------------------------------------+
//| hiredis redisReply object                                        |
//+------------------------------------------------------------------+
class RedisReply
  {
private:
   // reply reference
   int               m_reply;
   // reply type
   int               m_type;

   // array response
   int               m_array[];

   // for nested reply, only need to free the top level one
   int               m_needRelease;

public:
                     RedisReply(int ref,bool needRelease=true);
                    ~RedisReply() {if(m_needRelease) {mt4RedisReplyFree(m_reply);}}

   bool              isNil() const {return m_type==REDIS_REPLY_NIL;}
   bool              isError() const {return m_type==REDIS_REPLY_ERROR;}
   bool              isStatus() const {return m_type==REDIS_REPLY_STATUS;}

   bool              isString() const {return m_type==REDIS_REPLY_STRING;}
   bool              isInteger() const {return m_type==REDIS_REPLY_INTEGER;}
   bool              isArray() const {return m_type==REDIS_REPLY_ARRAY;}

   string            getString(void) const;
   bool              getStringAsBytes(char &array[]) const;
   bool              getStringAsInteger(int &value) const;

   long              getInteger() const {return mt4RedisReplyGetInteger(m_reply);}

   int               getSize() const {return ArraySize(m_array);}
   RedisReply       *getElement(int index) const {return new RedisReply(m_array[index],false);}
  };
//+------------------------------------------------------------------+
//| Contruct a reply object and for array reply get all element      |
//| references                                                       |
//+------------------------------------------------------------------+
RedisReply::RedisReply(int ref,bool needRelease)
  {
   m_reply=ref;
   m_needRelease=needRelease;
   m_type=mt4RedisReplyGetType(m_reply);
   if(m_type==REDIS_REPLY_ARRAY)
     {
      int size=mt4RedisReplyGetNumberOfElements(m_reply);
      if(size>0)
        {
         ArrayResize(m_array,size);
         for(int i=0; i<size; i++)
           {
            m_array[i]=mt4RedisReplyGetElement(m_reply,i);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Get reply string as a wide string                                |
//+------------------------------------------------------------------+
string RedisReply::getString(void) const
  {
   int buf;
   string s=mt4RedisReplyGetString(m_reply,buf);
   if(buf!=0)
     {
      mt4RedisReleaseStringBuffer(buf);
     }
   return s;
  }
//+------------------------------------------------------------------+
//| Get reply string as an integer                                   |
//+------------------------------------------------------------------+
bool RedisReply::getStringAsInteger(int &value) const
  {
   return mt4RedisReplyGetBytes(m_reply,value,4) == 0;
  }
//+------------------------------------------------------------------+
//| Get reply string as a byte array                                 |
//+------------------------------------------------------------------+
bool RedisReply::getStringAsBytes(char &array[]) const
  {
   int len=mt4RedisReplyGetLength(m_reply);
   if(ArraySize(array)<len)
     {
      ArrayResize(array,len);
     }
   return mt4RedisReplyGetBytes(m_reply, array, len)==0;
  }
//+------------------------------------------------------------------+
