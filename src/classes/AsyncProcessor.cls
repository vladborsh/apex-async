/**
 * @author Borsh Vlad  vlad.borsh@synebo.io
 * Handles chaining async jobs and runs flow. Also, it holds onError functionality 
 * if queue item does not provide error handling. Error invoking when exception occurred can be disabled,
 * and flow can be completed in spite of errors
 */
public with sharing class AsyncProcessor {

  List<Asyncable> queue;
  Asyncable onErrorAction;
  Boolean ignore;

  public AsyncProcessor() {
    this.queue = new List<Asyncable>();
    this.ignore = false;
  }

  public AsyncProcessor add( Asyncable promise ) {
    if ( promise != null ) {
      this.queue.add( promise );
    }
    return this;
  }

  public AsyncProcessor remove( Integer index ) {
    this.queue.remove( index );
    return this;
  }

  public AsyncProcessor onError( Asyncable promise ) {
    if ( promise != null ) {
      this.onErrorAction = promise;
    }
    return this;
  }

  public AsyncProcessor ignoreExceptions() {
    this.ignore = true;
    return this;
  }

  public Boolean isExceptionIgnored() {
    return this.ignore;
  }

  public Asyncable get( Integer index ) {
    return this.queue.get( index );
  }

  public Asyncable gerError() {
    return this.onErrorAction;
  }

  public Asyncable getFirstJob() {
    if ( this.queue != null && !this.queue.isEmpty() ) {
      return this.queue.remove(0);
    }
    return null;
  }

  public Id execute() {
    return System.enqueueJob( new AsyncUnit( this ) );
  }

}