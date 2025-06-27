# Cat Linked Function 实现

## 作用

可以间接调用外部函数，这样运行时的地址就不会跟外部函数的地址冲突了。

## 定义

结构如下: 外部函数名称1 外部函数名称2

在加载 Cat 代码的过程中，Linked Function 最终会被转换成地址。

## 实例

例子:
```C
void main()
{
    printf("Hello World");
}
```

转换成 Cat Lang
```C
Hello\cWorld  // 文本池
printf        // 链接池
              // 数字池
              // 数组池
0 0 1 0
```

地址 0 => 文本 "Hello World"  
地址 1 => 链接函数 "printf"  
地址 2 => 定义的 main 函数
