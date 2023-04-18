#ifndef BLOCKINGQUEUE_H
#define BLOCKINGQUEUE_H

#define QUEUE_SIZE 10

#include <QObject>
#include <QMutex>
#include <QMutexLocker>
#include <QWaitCondition>
#include <QDir>

#include <QDebug>

template <typename T>
class BlockingQueue
{
public:
    explicit BlockingQueue();
    ~BlockingQueue();

    T remove(qint32 index);
    void quit();

    void push(T value);
    T pop();

private:
    struct Node
    {
        T value = (T)nullptr;
        Node * next = nullptr;
    };

    Node *begin, *end;
    QMutex mutex;
    QWaitCondition emptyWait;
};

template<class T>
BlockingQueue<T>::BlockingQueue()
{
    begin = end = new Node;
}

template<typename T>
BlockingQueue<T>::~BlockingQueue()
{
    Node *temp;
    while(begin != end)
    {
        temp = begin;
        begin = temp->next;
        delete temp;
    }
    delete begin;
}
// 从队列删除一个节点（返回被删除节点保存的值）
template<typename T>
T BlockingQueue<T>::remove(qint32 index)
{
    QMutexLocker lock(&mutex);
    if(index < 0 || begin == end)
        return end->value;
    Node *frontNode = begin;
    T tempValue;   // 保存被删除节点的值
    if(index == 0) // 如果是(0)删除头节点
    {
        begin = frontNode->next;
        tempValue = frontNode->value;
        delete frontNode;
        return tempValue;
    }
    while(--index) // 寻找被删除节点的上一个节点
    {
        if((frontNode = frontNode->next) == end)
            return end->value;
    }
    Node *temp = frontNode->next;
    frontNode->next = temp->next;
    tempValue = temp->value;
    delete temp;
    return tempValue;
}

template<class T>
void BlockingQueue<T>::quit()
{
    mutex.lock();
    emptyWait.wakeAll();
    mutex.unlock();
}

template<typename T>
void BlockingQueue<T>::push(T value)
{
    mutex.lock();
    Node * temp = end;
    end = new Node;
    temp->value = value;
    temp->next = end;
    emptyWait.wakeOne();
    mutex.unlock();
}

template<typename T>
T BlockingQueue<T>::pop()
{
    mutex.lock();
    if(begin == end)
        emptyWait.wait(&mutex);
    if(begin == end)
        return end->value;
    T tempValue;   // 保存被删除节点的值
    Node * temp = begin;
    begin = temp->next;
    tempValue = temp->value;
    delete temp;
    mutex.unlock();
    return tempValue;
}

#endif // BLOCKINGQUEUE_H





















