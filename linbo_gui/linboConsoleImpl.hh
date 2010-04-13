#ifndef LINBOCONSOLEIMPL_HH
#define LINBOCONSOLEIMPL_HH

#include "ui_linboConsole.h"

#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstring.h>
#include <q3textbrowser.h>
#include <QTextBrowser>
#include <qlineedit.h>

#include "linboDialog.hh"

using namespace Ui;

class linboConsoleImpl : public QWidget, public Ui::linboConsole, public linboDialog
{
  Q_OBJECT
  
private:
  QProcess* mysh;
  QStringList myCommand;
  QString line;
  QWidget *myMainApp, *myParent;
  Q3TextBrowser *Console;

public:
  linboConsoleImpl( QWidget* parent = 0 );

  ~linboConsoleImpl();

  void setTextBrowser( Q3TextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setMainApp( QWidget* newMainApp );


public slots:
  virtual void postcmd();
  virtual void precmd();
  void readFromStderr();
  void readFromStdout();
  void showOutput();
  void execute();
};
#endif
