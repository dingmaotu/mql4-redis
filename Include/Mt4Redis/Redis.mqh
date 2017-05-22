//+------------------------------------------------------------------+
//|                                                        Redis.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "RedisBase.mqh"
#include "Utils.mqh"
//+------------------------------------------------------------------+
//| Redis client except pub/sub                                      |
//+------------------------------------------------------------------+
class Redis: public RedisBase
  {
public:
                     Redis(RedisContext *c):RedisBase(c) {}

   //--- key management
   int               keys(const string pattern,string &keys[])
     {return arrayCommand("keys "+pattern,keys);}
   int               del(const string &keys[])
     {return(int)integerCommand("del "+StringJoin(keys));}
   int               del(const string key)
     {return(int)integerCommand("del "+key);}
   bool              exists(const string key)
     {return integerCommand("exists "+key)==1;}
   string            type(const string key)
     {return stringCommand("type "+key);}

   //--- key expiration
   bool              expire(const string key,int seconds)
     {return integerCommand(StringFormat("expire %s %d",key,seconds))==1;}
   bool              pexpire(const string key,int milliseconds)
     {return integerCommand(StringFormat("pexpire %s %d",key,milliseconds))==1;}
   bool              persist(const string key)
     {return integerCommand("persist "+key)==1;}
   long              ttl(const string key)
     {return integerCommand("ttl "+key);}
   long              pttl(const string key)
     {return integerCommand("pttl "+key);}

   //--- string
   bool              set(const string key,const string value,long ex=0,long px=0,bool nx=false,bool xx=false);
   bool              mset(const string &keys[],const string &values[],bool nx=false)
     {
      if(nx) return integerCommand("msetnx "+StringPairJoin(keys,values))==1;
      else return statusCommand("mset "+StringPairJoin(keys,values));
     }
   string            get(const string key)
     {return stringCommand("get "+key);}
   int               mget(const string &keys[],string &values[])
     {return arrayCommand("mget "+StringJoin(keys),values);}
   string            getset(const string key,const string value)
     {return stringCommand(StringFormat("getset %s %s",key,value));}

   long              incr(const string key,long by=1)
     {return integerCommand(by==1?StringFormat("incr %s",key):StringFormat("incrby %s %d",key,by));}
   long              decr(const string key,long by=-1)
     {return integerCommand(by==-1?StringFormat("decr %s",key):StringFormat("decrby %s %d",key,by));}
   double            incr(const string key,double by)
     {
      string s=stringCommand(StringFormat("incrbyfloat %s %f",key,by));
      if(s!=NULL)return StringToDouble(s);else return NULL;
     }

   long              setrange(const string key,int offset,string value)
     {return integerCommand(StringFormat("setrange %s %d %s",key,offset,value));}
   string            getrange(const string key,int s,int e)
     {return stringCommand(StringFormat("getrange %s %d %d",key,s,e));}
   long              append(const string key,string value)
     {return integerCommand(StringFormat("append %s %s",key,value));}
   long              strlen(const string key)
     {return integerCommand("strlen "+key);}

   //--- hash
   int               hkeys(const string key,string &items[])
     {return arrayCommand("hkeys "+key,items);}
   int               hvals(const string key,string &items[])
     {return arrayCommand("hvals "+key,items);}
   long              hlen(const string key)
     {return integerCommand("hlen "+key);}
   bool              hexists(const string key,const string field)
     {return integerCommand(StringFormat("hexists %s %s",key,field))==1;}
   bool              hset(const string key,const string field,const string value,bool nx=false)
     {
      if(nx) return integerCommand(StringFormat("hsetnx %s %s %s",key,field,value))==1;
      else return integerCommand(StringFormat("hset %s %s %s",key,field,value))!=NULL;
     }
   void              hmset(const string key,const string &fields[],const string &values[])
     {statusCommand("hmset "+key+" "+StringPairJoin(fields,values));}
   string            hget(const string key,const string field)
     {return stringCommand(StringFormat("hget %s %s",key,field));}
   int               hmget(const string key,const string &fields[],string &values[])
     {return arrayCommand("hmget "+key+" "+StringJoin(fields),values);}
   int               hgetall(const string key,string &items[])
     {return arrayCommand("hgetall "+key,items);}
   long              hdel(const string key,const string &fields[])
     {return integerCommand(StringFormat("hdel %s %s",key,StringJoin(fields)));}
   long              hdel(const string key,const string field)
     {return integerCommand(StringFormat("hdel %s %s",key,field));}
   long              hincr(const string key,const string field,long by=1)
     {return integerCommand(StringFormat("hincrby %s %s %d",key,field,by));}
   double            hincr(const string key,const string field,double by)
     {
      string s=stringCommand(StringFormat("hincrbyfloat %s %s %f",key,field,by));
      if(s!=NULL)return StringToDouble(s); else return NULL;
     }
   long              hstrlen(const string key,const string field)
     {return integerCommand(StringFormat("hstrlen %s %s",key,field));}
  };
//+------------------------------------------------------------------+
//| Redis super set command. No need for setnx setex psetex          |
//+------------------------------------------------------------------+
bool Redis::set(const string key,const string value,long ex=0,long px=0,bool nx=false,bool xx=false)
  {
   if(nx && xx)
     {
      throw("nx and xx can not both be true.");
      return false;
     }
   string command=StringFormat("set %s %s",key,value);
   if(ex>0)
     {
      command+=" ex "+IntegerToString(ex);
     }
   if(px>0)
     {
      command+=" px "+IntegerToString(px);
     }
   if(nx)
     {
      command+=" nx";
     }
   if(xx)
     {
      command+=" xx";
     }
   return statusCommand(command);
  }
//+------------------------------------------------------------------+
