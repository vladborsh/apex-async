/**
 * @author Borsh Vlad  vlad.borsh@synebo.io
 * Provides handling for the single async job from the queue, 
 * invoke success items and error items in the case when the exception has occurred. 
 * If current async job does not provide on fail job (it returns null), invoke general error handling from processor
 */
public class AsyncUnit  implements Queueable, Database.AllowsCallouts {

  AsyncProcessor processor;
  Asyncable currentAsyncJob;
  Asyncable promise;

  public AsyncUnit( AsyncProcessor processor ) {
    this.processor = processor;
  }

  public AsyncUnit( Asyncable promise ) {
    this.promise = promise;
  }

  public void execute( QueueableContext context ) {
    try {
      /* If processor isn't empty, obtain first async job from queue and do */
      if ( this.processor != null) {
        this.currentAsyncJob = processor.getFirstJob();
        if ( this.currentAsyncJob != null ) {
          this.currentAsyncJob.doJob();
          /* If work is completed correctly, add onSuccess item the beginning of queue */
          processor.add( this.currentAsyncJob.onSuccess() );
        }
        /* Go to the next step in queue */
        System.enqueueJob( new AsyncUnit( processor ) );
      } 
      /* If instead of processor has provided the single promise, do job */
      else if ( this.promise != null ) {
        promise.doJob();
         /* If work is completed correctly, do onSuccess item on the next step */
        System.enqueueJob( new AsyncUnit( promise.onSuccess() ) );
      }
    } catch ( Exception e ) {
      if ( this.processor != null ) {
        /* If work is completed with unhandled exception, add onFail item the beginning of queue */
        Asyncable onFailAsyncJob = this.currentAsyncJob.onFail();
        if ( onFailAsyncJob != null ) {
          processor.add( onFailAsyncJob );
          /* Go to the next step in queue */
          System.enqueueJob( new AsyncUnit( processor ) );
        } else {
          /* If onFail item not provided for current async job, invoke geral error prom async processor */
          if ( processor.isExceptionIgnored() ) {
            System.enqueueJob( new AsyncUnit( processor ) );
          } else {
            System.enqueueJob( new AsyncUnit( processor.gerError() ) );
          }
        }
      } else if ( this.promise != null ) {
        Asyncable onFailAsyncJob = this.promise.onFail();
        if ( onFailAsyncJob != null ) {
          System.enqueueJob( new AsyncUnit( onFailAsyncJob ) );
        }
      }
    }
  }

}