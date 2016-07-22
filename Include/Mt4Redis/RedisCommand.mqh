//+------------------------------------------------------------------+
//|                                                 RedisCommand.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                                dingmaotu@126.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@126.com"
#property strict
/**
 * Due to lack of 1) generic type arguments like void, 2) variable length
 * argments, it is very difficult to write a generic data type -> binary
 * function. (Though you have them in built-in functions like StringFormat,
 * ArrayResize, etc. it is not usable in your own code. F**k)
 *
 * However, you can work around this in two ways:
 * 
 * 1. Overload multiple functions with different argument types (the C side
 *    only has one function accepting a void pointer). It needs you to add
 *    your own #import to use a new type, but it can support any type in MQL4
 *
 * 2. Or you can use struct assignment to convert any struct to a char array:
 *    struct MyType {int a; long b;}
 *    struct MyTypeBytes {char value[12];}
 *    MyTypeBytes b;
 *    MyType a;
 *    a.a = 5;
 *    a.b = 6;
 *    b = a;
 *    mt4RedisCommandAppendBytes(cmd, b.value, 12);
 */

#import "Mt4Redis.dll"
int       mt4RedisCommandNew();
void      mt4RedisCommandDelete(int);
void      mt4RedisCommandClear(int);
void      mt4RedisCommandAppendString(int,const string &value);
void      mt4RedisCommandAppendBytes(int,const char &value[],int size);
void      mt4RedisCommandAppendBytes(int,int &value,int size);
#import

//+------------------------------------------------------------------+
//| Construct a complex Redis command which includes binary          |
//| contents.                                                        |
//+------------------------------------------------------------------+
class RedisCommand
  {
   int               m_ref;
public:
                     RedisCommand() {m_ref=mt4RedisCommandNew();}
                    ~RedisCommand() {mt4RedisCommandDelete(m_ref);}

   void              append(const string value) {mt4RedisCommandAppendString(m_ref,value);}
   void              append(const char &value[]) {mt4RedisCommandAppendBytes(m_ref,value,ArraySize(value));}
   void              append(int value) {mt4RedisCommandAppendBytes(m_ref,value,4);}

   void              clear() {mt4RedisCommandClear(m_ref);}
   int               getRef() const {return m_ref;}
  };
//+------------------------------------------------------------------+
