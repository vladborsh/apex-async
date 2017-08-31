@isTest
public class AsyncUnitTest {

  @isTest
  public static void testExecute() {
    AsyncUnit aUnit = new AsyncUnit( new TestAsyncQueuable() )
      .success( new TestAsyncQueuable() )
      .setProcessor( new AsyncProcessor() );
    Test.startTest();
    System.enqueueJob( aUnit );
    Test.stopTest();
  }

  @isTest
  public static void testSuccess() {
    AsyncUnit aUnit = new AsyncUnit( new TestAsyncQueuable() )
      .success( new TestAsyncQueuable() );
  }

  @isTest
  public static void testFail() {
    AsyncUnit aUnit = new AsyncUnit( new TestAsyncQueuable() )
      .fail( new TestAsyncQueuable() );
  }

  @isTest
  public static void testSetProcessor() {
    AsyncUnit aUnit = new AsyncUnit( new TestAsyncQueuable() )
      .setProcessor( new AsyncProcessor() );
  }

  public class TestAsyncQueuable implements Queueable {
    public void execute( QueueableContext context ) {
      List<Account> accList = [SELECT Id FROM Account];
    }
  }

  public class TestAsyncFailedQueuable implements Queueable {
    public void execute( QueueableContext context ) {
      throw new AsyncProcessorException('Crash it');
    }
  }

}