/**
 * @author Borsh Vlad  vlad.borsh@synebo.io
 * Shloud be implemented by any class before holding in async processor
 */
public interface Asyncable {

  void doJob();

  Asyncable onSuccess();

  Asyncable onFail();

}