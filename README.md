# Apex Async

Take control of your asynchronous Apex processes by using apex-async.
The core idea is in composing asynchronous parts of the complex flow into the single chain and run all process from one place. This parts can be branched regarding the success or failure of the previous part.

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## How to

First, one or more classes which represent business logic should implement Queueable interface. Then create AsyncUnit instances from them. You can specify success flow or failure flow for every single unit. Concatenate async units with AsyncProcessor class and execute it. Please notes, if you've not specified failure flow, the processor will call the general on-error action. If general on-error action also hasn't specified exception won't be processed.

### Make the chain

Join several (**then**) tasks in one process with **AsyncProcessor** and run it 

```java
AsyncProcessor aProcessor = new AsyncProcessor()
.then( 
  new AsyncUnit( new AccountUpdaterQueuable() ) 
)
.then( 
  new AsyncUnit( new ContactRemoteUpdaterQueuable() ) 
)
.then( 
  new AsyncUnit( new LoggerQueuable() ) 
)
.execute();
```

Create process with initial task

```java
AsyncProcessor aProcessor = new AsyncProcessor(
  new AsyncUnit( new ContactRemoteUpdaterQueuable() )
)
.then( 
  new AsyncUnit( new AccountUpdaterQueuable() ) 
)
.execute();
```

Use **fail** function in **AsyncProcessor** for general handling errors

```java
AsyncProcessor aProcessor = new AsyncProcessor()
.then( 
  new AsyncUnit( new AccountUpdaterQueuable() ) 
)
.fail( 
  new AsyncUnit( new LoggerQueuable() ) 
)
.execute();
```

### Handle particular success and failure

Use **fail** function in **AsyncUnit** for particular handling errors

```java
AsyncProcessor aProcessor = new AsyncProcessor()
.then( 
  new AsyncUnit( new AccountUpdaterQueuable() ) 
    .fail( new AccountUpdaterLogger() )
)
.fail( 
  new AsyncUnit( new LoggerQueuable() ) 
)
.execute();
```

Use **success** function in **AsyncUnit** for handling success from particular operation

```java
AsyncProcessor aProcessor = new AsyncProcessor()
.then( 
  new AsyncUnit( new AccountUpdaterQueuable() ) 
    .success( new ContactRemoteUpdaterQueuable() )
    .fail( new AccountUpdaterLogger() )
)
.then( 
  new AsyncUnit( new OpportunityJobQueuable() ) 
    .success( new ContactRemoteUpdaterQueuable() )
    .fail( new OpportunityLogger() )
)
.execute();
```

### Pass data from one job to another

For passing state from one job to another your classes should implement **AsyncProcessor.Emitter** and **AsyncProcessor.Acceptor** respectively. Example:

```java
/* Create emitter class */
public class RemoteUpdater implements Queueable, AsyncProcessor.Emitter {
  private String responseBody;
  public void execute( QueueableContext context ) {
    /* Make callout */
    HTTPResponse res = http.send(req);
    this.responseBody = res.getBody();
  }
  public Object emit() {
    return this.responseBody;
  }
}

/* Create acceptor class */
public class APILogger implements Queueable, AsyncProcessor.Acceptor {
  private String responseBody;
  public void execute( QueueableContext context ) {
    /* Another business logic */
    insert new API_Log__c( 
      Response__c = this.responseBody
    );
  }
  public void accept( Object body ) {
    this.responseBody = (String) body;
  }
}

/* Create and execute flow */
AsyncProcessor aProcessor = new AsyncProcessor(
  new AsyncUnit( new RemoteUpdater() ) 
)
.then( 
  new AsyncUnit( new APILogger() )
)
.execute();
```
