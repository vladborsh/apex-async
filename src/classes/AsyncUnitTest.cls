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
    Test.startTest();
    System.enqueueJob( aUnit );
    Test.stopTest();
  }

  @isTest
  public static void testFail() {
    AsyncUnit aUnit = new AsyncUnit( 
      new TestAsyncFailedQueuable() 
    )
    .fail( new TestAsyncQueuable() );
    Test.startTest();
    System.enqueueJob( aUnit );
    Test.stopTest();
  }

  @isTest
  public static void testSetProcessor() {
    AsyncUnit aUnit = new AsyncUnit( new TestAsyncQueuable() )
      .setProcessor( new AsyncProcessor() );
    Test.startTest();
    System.enqueueJob( aUnit );
    Test.stopTest();
  }

  @isTest
  public static void testAcceptAndEmit() {
    AsyncProcessor aProcessor = new AsyncProcessor(
      new AsyncUnit( new TestEmiter() ) 
    )
    .then( 
      new AsyncUnit( new TestAcceptor() ) 
    );
    Test.startTest();
    aProcessor.execute();
    Test.stopTest();
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

  public class TestEmiter implements Queueable, AsyncProcessor.Emitter {
    List<Account> accountList;
    public void execute( QueueableContext context ) {
      this.accountList = [SELECT Id FROM Account];
    }
    public Object emit() {
      return this.accountList;
    }
  }

  public class TestAcceptor implements Queueable, AsyncProcessor.Acceptor {
    List<Account> accountList;
    public void execute( QueueableContext context ) {
      for ( Account account_i : accountList ) {
        account_i.Name = 'Test';
      }
    }
    public void accept( Object obj ) {
      this.accountList = (List<Account>)obj;
    }
  }

}