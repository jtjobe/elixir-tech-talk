Task.start
# Starts a task.
# This is only used when the task is used for side-effects (i.e. no interest in the returned result) and it should not be linked to the current process.
Task

Conveniences for spawning and awaiting tasks.

Tasks are processes meant to execute one particular action throughout their lifetime, often with little or no communication with other processes. The most common use case for tasks is to convert sequential code into concurrent code by computing a value asynchronously:

task = Task.async(fn -> do_some_work() end)
res  = do_some_other_work()
res + Task.await(task)
