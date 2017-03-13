#ifndef FORTSCHRITTDIALOG_H
#define FORTSCHRITTDIALOG_H

#include <QDialog>
#include <qobject.h>
#include <QProcess>
#include <QTextEdit>
#include <QTime>
#include <qbytearray.h>

#include "linboLogConsole.h"
#include "aktion.h"
#include "filter.h"
#include "filtertime.h"

namespace Ui {
class FortschrittDialog;
}

class linboLogConsole;

class FortschrittDialog : public QDialog
{
    Q_OBJECT
private:
    bool active;
    QString cmd;
    QString title;
    bool ldetails;
    bool* details;
    QProcess *process;
    bool connected;
    linboLogConsole *logDetails, *logConsole;
    int timerId;
    Filter *filter;

public:
    explicit FortschrittDialog(QWidget *parent = 0, bool new_active = true, QStringList* command = 0, linboLogConsole *new_log = 0,
                               const QString& new_title  = NULL, Aktion aktion = Aktion::None,
                               bool* newDetails = NULL,
                               Filter *new_filter = 0);
    ~FortschrittDialog();

    void setShowCancelButton(bool show);
    void setProcess(QProcess *new_process);
    void keyPressEvent(QKeyEvent *);

public slots:
    void killLinboCmd();
    void appendTitle(const QString& new_title);

private slots:
    void processReadyReadStandardError();
    void processReadyReadStandardOutput();
    void processFinished( int exitCode, QProcess::ExitStatus exitStatus );

    void on_details_toggled(bool checked);

    void on_cancelButton_clicked();

protected:
    void timerEvent(QTimerEvent *event);

private:
    Ui::FortschrittDialog *ui;
};

#endif // FORTSCHRITTDIALOG_H
