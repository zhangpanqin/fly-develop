<img src="http://oss.mflyyou.cn/blog/20200813205639.png?author=zhangpanqin" alt="List" style="zoom:50%;" />

### ArrayList

```java
public class ArrayList<E> extends AbstractList<E>{
    /**
     * 保存的数据，capacity 为 elementData 的长度。
     * int newCapacity = oldCapacity + (oldCapacity >> 1);
     */
    transient Object[] elementData;
    
    // ArrayList 为线程不安全的集合。modCount 用于判断并发修改。快速失败
    protected transient int modCount = 0;
    /**
     * list 中元素的数量，elementData 哪些 index 有元素
     */
    private int size;
    
    // 获取某个索引上的元素
    public E get(int index);
	
    // 替换某个索引上的元素
    public E set(int index, E element);
	
    // 在某个索引处，插入元素；index 和其之后的元素往后移
    public void add(int index, E element);
    
    // 移除某个索引上的元素，后续元素向前移动
    public E remove(int index);
    
    // 从当前 List 中移除 c 中的元素，并将空余的位置元素整理
    public boolean removeAll(Collection<?> c);
    
    // 当前 List 只包含 c 中的元素，别的元素去除掉 
    public boolean retainAll(Collection<?> c);
    
    // 返回 size，当前 List 中有多少个元素
    public int size();
    
    // 正序遍历 List，返回 o 第一次出现的索引（equals），不存在返回 -1
    public int indexOf(Object o);
    
    // 倒叙遍历 List，返回 o 第一次出现的索引（equals），不存在返回 -1
    public int lastIndexOf(Object o);
    
    // List 转换为数组
    public <T> T[] toArray(T[] a);
    
    // 增强 for 遍历 List
    public void forEach(Consumer<? super E> action)
}
```

<img src="http://oss.mflyyou.cn/blog/20200813213629.svg?author=zhangpanqin" alt="未命名文件" style="zoom:50%;" />

`ArrayList` 底层是数组，数组会动态扩容。

当前 `elementData` 长度没有位置可以放置元素时，会进行扩容，算法：`int newCapacity = oldCapacity + (oldCapacity >> 1)` 。比如原来 `capacity` 为 5，当 List 添加了 5 个元素。添加第六个时候，会触发扩容 ，扩容之后 `elementData` 长度为 `5 + 5/2 = 7` 。扩容之后会使用 `elementData` 将原来 List 的元素复制到新的数组中。

当进行元素的 `remove` 操作时，会将别的元素往前移，填补空缺。

`protected transient int modCount = 0;` 用于判断调用 api 的时候，是否同时有别的线程调用了 List 的 api 。用于并发修改的判断。

```java
public class ArrayListDemo {

    private List<String> data;

    @Before
    public void before() {
        data = new ArrayList<>(5);
        data.add("a");
        data.add("b");
        data.add("c");
        data.add("d");
        data.add("e");
    }

    @Test
    public void simple() {
        // a
        System.out.println(data.get(0));
        // e
        System.out.println(data.get(4));
        // 5
        System.out.println(data.size());
    }

    @Test
    public void set() {
        data.set(2, "33");
        // [a, b, 33, d, e]
        System.out.println(data);
    }

    @Test
    // 在某个索引处，插入元素；index 和其之后的元素往后移
    public void add() {
        data.add(2, "33");
        // [a, b, 33, c, d, e]
        System.out.println(data);
    }

    @Test
    // 移除某个索引上的元素，后续元素向前移动
    public void remove() {
        // 移除索引为 2 的元素 c
        data.remove(2);
        // [a, b, d, e]
        System.out.println(data);
    }

    @Test
    // 从当前 List 中移除 c 中的元素，并将空余的位置元素整理
    public void removeAll() {
        data.removeAll(Arrays.asList("a", "d", "e"));
        // [b, c]
        System.out.println(data);
    }

    @Test
    // 当前 List 只包含 c 中的元素，别的元素去除掉 
    public void retainAll(){
        data.retainAll(Arrays.asList("a", "e"));
        // [a, e]
        System.out.println(data);
    }
}
```



### LinkedList





### Vector





### Stack