# unityC#脚本中的委托和事件

## 1.委托

委托是一种方法的容器，可以存储不同的函数，这些函数可以有不同的参数和返回值，也可以是相同的参数和返回值，简单的创建委托的语法如下：

（这里创建了一个接收float类型参数，返回值为void的委托）

```c#
public class CapsuleTest : MonoBehaviour
{

    delegate void DelegeteInSingleObj(float num);
    DelegeteInSingleObj testDelegate;

    void Moving(float num)
    {
        transform.Translate(num, -num, num / 2);
    }

    void SelfRotate(float num)
    {
        transform.rotation *= Quaternion.Euler(num,0,0);
    }

    void Start()
    {
        testDelegate += Moving; 
        testDelegate += SelfRotate;
    }

    void Update()
    {
        testDelegate(Time.deltaTime);
    }
}
```

创建委托时，我们使用delegate关键字创建，同时实例化一个委托对象。

当以上程序执行时，会同时处理两件事：移动物体和旋转物体。

如果想要用委托存储不同参数不同返回值的方法，可以使用类似于函数重载的方式重载委托。

## 2.事件

事件是一种类似于委托的容器，唯一不同之处在于事件只能存储无参数void返回值的函数，而且需要先定义一个委托才能使用，示例如下：

```c#
public class EventManager : MonoBehaviour 
{
    public delegate void ClickAction();
    public static event ClickAction OnClicked;


    void OnGUI()
    {
        if(GUI.Button(new Rect(Screen.width / 2 - 50, 5, 100, 30), "Click"))
        {
            if(OnClicked != null)
                OnClicked();
        }
    }
}
```

定义事件使用的是event关键字，这里为了方便调用事件，将其修饰为静态。

调用示例如下：

（这里使用两个脚本分别绑定到两个物体上）

```c#
public class TeleportScript : MonoBehaviour 
{
    void OnEnable()
    {
        EventManager.OnClicked += Teleport;
    }


    void OnDisable()
    {
        EventManager.OnClicked -= Teleport;
    }


    void Teleport()
    {
        Vector3 pos = transform.position;
        pos.y = Random.Range(1.0f, 3.0f);
        transform.position = pos;
    }
}
```

```c#
public class TurnColorScript : MonoBehaviour 
{
    void OnEnable()
    {
        EventManager.OnClicked += TurnColor;
    }


    void OnDisable()
    {
        EventManager.OnClicked -= TurnColor;
    }


    void TurnColor()
    {
        Color col = new Color(Random.value, Random.value, Random.value);
        renderer.material.color = col;
    }
}
```

需要注意的是，为了避免内存泄漏，我们在调用完存入事件的方法以后要把对应的方法移出事件。