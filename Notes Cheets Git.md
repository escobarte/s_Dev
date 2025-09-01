```
git add . && git commit -m"Re-Bracnh+workflow-Rrules [skip ci]$(date +%m-%d_%H-%M-%S)" && git push
git add . && git commit -m"Re-Bracnh+workflow:Rrules [skip ci]" && git push
git commit -m"Re-Bracnh+workflow:Rrules [skip ci] = ignore to run Pipeline
```

```
Для себя заметка: Я сделал Push, сё прошло успешно. Но я забыл добавить одну строчку кода. Что я сделал:
Добавил код, и когда запушил вставил [skip ci] чтобы не перезпускать *pipeline*. 
И потом просто в ручную перезапустил последний Job.
```
