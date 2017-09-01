@isTest
public with sharing class AsyncProcessorTest {
	
  @isTest
  public static void testThen() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    AsyncProcessor aProcessorSec = new AsyncProcessor( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    )
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
  }

  @isTest
  public static void testRemove() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    )
    .remove( 0 );
  }

  @isTest
  public static void testFail() {
    AsyncProcessor aProcessor = new AsyncProcessor(
      new AsyncUnit( new AsyncUnitTest.TestAsyncFailedQueuable() )
    )
    .fail( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    Test.startTest();
    aProcessor.execute();
    Test.stopTest();
  }

  @isTest
  public static void testGet() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    AsyncUnit aUnit = aProcessor.get( 0 );
  }

  @isTest
  public static void testGetError() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .fail( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    AsyncUnit aUnit = aProcessor.getError();
  }

  @isTest
  public static void testGetFirstJob() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    AsyncUnit aUnit = aProcessor.getFirstJob();
  }

  @isTest
  public static void testIsNotEmpty() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    Boolean isNtEmpty = aProcessor.isNotEmpty();
  }

  @isTest
  public static void testExecute() {
    AsyncProcessor aProcessor = new AsyncProcessor()
    .then( 
      new AsyncUnit( new AsyncUnitTest.TestAsyncQueuable() ) 
    );
    Test.startTest();
    aProcessor.execute();
    Test.stopTest();
  }

}