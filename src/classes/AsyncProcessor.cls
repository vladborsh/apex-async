/**
 * @author Borsh Vlad  vlad.borsh@synebo.io
 * Handles chaining async jobs and runs flow. Error invoking when exception occurred can be disabled,
 * and flow can be completed in spite of errors
 */
public with sharing class AsyncProcessor {

  List<AsyncUnit> queue;
  AsyncUnit onErrorAction;

  public AsyncProcessor() {
    this.queue = new List<AsyncUnit>();
  }

  public AsyncProcessor( AsyncUnit unit ) {
    this.queue = new List<AsyncUnit>();
    if ( unit != null ) {
      this.queue.add( unit );
    }
  }

  public AsyncProcessor then( AsyncUnit unit ) {
    if ( unit != null ) {
      this.queue.add( unit );
    }
    return this;
  }

  public AsyncProcessor remove( Integer index ) {
    this.queue.remove( index );
    return this;
  }

  public AsyncProcessor fail( AsyncUnit unit ) {
    if ( unit != null ) {
      this.onErrorAction = unit;
    }
    return this;
  }

  public AsyncUnit get( Integer index ) {
    return this.queue.get( index );
  }

  public AsyncUnit getError() {
    return this.onErrorAction;
  }

  public AsyncUnit getFirstJob() {
    if ( this.queue != null && !this.queue.isEmpty() ) {
      return this.queue.remove(0);
    }
    return null;
  }

  public Boolean isNotEmpty() {
    return this.queue != null && !this.queue.isEmpty();
  }

  public Id execute() {
    return System.enqueueJob( 
      this.getFirstJob()
        .setProcessor( this )
    );
  }

  public interface Emitter {
    Object emit();
  }

  public interface Acceptor {
    void accept( Object obj );
  }

}