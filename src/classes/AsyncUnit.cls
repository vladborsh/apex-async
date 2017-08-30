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
        currentQueueableJob.execute( context );
        if ( successQueueableJob != null ) {
          System.enqueueJob( 
            new AsyncUnit( successQueueableJob ) 
              .setProcessor( processor )
          );
          return;
        }
        if ( processor.isNotEmpty() ) {
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
        return;
      } else if ( processor.gerError() != null ) {
        System.enqueueJob( 
          new AsyncUnit( processor.gerError() ) 
        );
      }
    }
  }

}