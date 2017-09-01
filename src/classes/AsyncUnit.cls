/**
 * @author Borsh Vlad  vlad.borsh@synebo.io
 * Provides handling for the single async job from the queue, 
 * invoke success items and error items in the case when the exception has occurred. 
 * If current async job does not provide on fail job (it returns null), invoke general error handling from processor
 */
public class AsyncUnit  implements Queueable, Database.AllowsCallouts {

  Queueable currentQueueableJob;
  Queueable successQueueableJob;
  Queueable failQueueableJob;
  AsyncProcessor processor;
  Object tempData;

  public AsyncUnit( Queueable queueableJob ) {
    this.currentQueueableJob = queueableJob;
  }

  public AsyncUnit success( Queueable queueableJob ) {
    this.successQueueableJob = queueableJob;
    return this;
  }

  public AsyncUnit fail( Queueable queueableJob ) {
    this.failQueueableJob = queueableJob;
    return this;
  }

  public AsyncUnit setProcessor( AsyncProcessor processor ) {
    this.processor = processor;
    return this;
  }

  public void execute( QueueableContext context ) {
    try {
      if ( currentQueueableJob != null ) {
        if ( currentQueueableJob instanceof AsyncProcessor.Acceptor 
          && tempData != null
        ) {
          ((AsyncProcessor.Acceptor)currentQueueableJob).accept( tempData );
        }
        currentQueueableJob.execute( context );
        tempData = null;
        if ( successQueueableJob != null ) {
          if ( currentQueueableJob instanceof AsyncProcessor.Emitter 
            && successQueueableJob instanceof AsyncProcessor.Acceptor
          ) {
            ((AsyncProcessor.Acceptor)successQueueableJob).accept( ((AsyncProcessor.Emitter)currentQueueableJob).emit() );
          } 
          System.enqueueJob( 
            new AsyncUnit( successQueueableJob ) 
              .setProcessor( processor )
          );
          return;
        }
        if ( processor.isNotEmpty() ) {
          if ( currentQueueableJob instanceof AsyncProcessor.Emitter ) {
            tempData = ((AsyncProcessor.Emitter)currentQueueableJob).emit();
          } else {
            tempData = null;
          }
          System.enqueueJob( 
            processor.getFirstJob()
              .setProcessor( processor )
          );
          return;
        }
      }
      return;
    } catch ( Exception e ) {
      if ( failQueueableJob != null ) {
        System.enqueueJob( 
          new AsyncUnit( failQueueableJob ) 
            .setProcessor( processor )
        );
      } else if ( processor.getError() != null ) {
        System.enqueueJob( 
          new AsyncUnit( processor.getError() ) 
        );
      }
    }
  }

}