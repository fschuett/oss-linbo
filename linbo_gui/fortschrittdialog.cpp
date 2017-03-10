#include <typeinfo>

#include <qdebug.h>
#include <unistd.h>
#include <QDesktopWidget>
#include <qdialog.h>
#include <qprocess.h>
#include <qbytearray.h>
#include <qevent.h>

#include "linboLogConsole.h"
#include "aktion.h"
#include "linboremote.h"
#include "filtertime.h"
#include "fortschrittdialog.h"
#include "ui_fortschrittdialog.h"

/**
 * @brief FortschrittDialog::FortschrittDialog
 * @param parent
 * @param new_active true: execute command in own process, false: show dialog and wait for process to finish
 * @param command
 * @param new_log
 * @param titel
 * @param aktion
 * @param newDetails
 * @param new_filter
 */
FortschrittDialog::FortschrittDialog(QWidget* parent, bool new_active, QStringList* command, linboLogConsole* new_log,
                                     const QString& titel, Aktion aktion, bool* newDetails,
                                     Filter *new_filter):
    QDialog(parent), active(new_active), details(newDetails), process((new_active?new QProcess(this):NULL)), logConsole(new_log), logDetails(),
    timerId(0), filter(new_filter),
    ui(new Ui::FortschrittDialog)
{
    ui->setupUi(this);
    if(details == NULL){
        details = new bool(false);
    }
    ui->details->setChecked(*details);
    logDetails = new linboLogConsole();
    logDetails->setLinboLogConsole(logConsole == NULL ? linboLogConsole::COLORSTDOUT
                                                        : logConsole->get_colorstdout(),
                                     logConsole == NULL ? linboLogConsole::COLORSTDERR
                                                        : logConsole->get_colorstderr(),
                                     ui->log, NULL);
    ui->aktion->setText(titel == NULL ? QString("unbekannt") : titel );
    if(aktion == Aktion::None) {
        ui->folgeAktion->hide();
    } else {
        ui->folgeAktion->setText(aktion.toQString());
    }
    if(active){
        connect( process, &QProcess::readyReadStandardOutput,
             this, &FortschrittDialog::processReadyReadStandardOutput);
        connect( process, &QProcess::readyReadStandardError,
             this, &FortschrittDialog::processReadyReadStandardError);
        connect( process, SIGNAL(finished(int,QProcess::ExitStatus)),
             this, SLOT(processFinished(int,QProcess::ExitStatus)));

        //args need to be passed separate because of empty args
        cmd = command->at(0);
        QStringList args = *command;
        args.removeFirst();
        const QStringList cargs = args;
        process->start(cmd, args, QIODevice::ReadWrite );
    }
    if(filter == 0){
        filter = new FilterTime(ui->processTime);
    }
    ui->progressBar->setMaximum(filter->maximum());
    ui->progressBar->setValue(filter->value());
    timerId = startTimer( 1000 );
}

FortschrittDialog::~FortschrittDialog()
{
    if(filter != 0)
        if(typeid(*filter) == typeid(FilterTime)){
            delete filter;
        }
    delete ui;
}

void FortschrittDialog::killLinboCmd() {

    if(active){
        process->terminate();
    }
    ui->aktion->setText("Die Ausführung wird abgebrochen...");
    ui->cancelButton->setEnabled( false );
    QTimer::singleShot( 10000, this, SLOT( close() ) );

}

void FortschrittDialog::timerEvent(QTimerEvent *event) {
    if(event->timerId() == timerId){
        ui->processTime->setTime(ui->processTime->time().addSecs(1));
        if(typeid(*filter) == typeid(FilterTime)){
            ui->progressBar->setValue(filter->value());
        }
        if(!active && !LinboRemote::is_running()){
            close();
        }
    }
}

void FortschrittDialog::processReadyReadStandardOutput()
{
    if(!active){
        return;
    }
    QByteArray data = process->readAllStandardOutput();
    filter->filter(data);
    if(filter->maximum() != ui->progressBar->maximum())
        ui->progressBar->setMaximum(filter->maximum());
    ui->progressBar->setValue(filter->value());
    logDetails->writeStdOut(data);
    if(logConsole != NULL)
        logConsole->writeStdOut(data);
}

void FortschrittDialog::processReadyReadStandardError()
{
    if(!active){
        return;
    }
    QByteArray data = process->readAllStandardError();
    logDetails->writeStdErr(data);
    if(logConsole != NULL)
        logConsole->writeStdErr(data);
}

void FortschrittDialog::processFinished( int exitCode, QProcess::ExitStatus exitStatus ) {
    if( timerId != 0) {
        this->killTimer( timerId );
        timerId = 0;
    }
    if(logConsole != NULL){
        logConsole->writeStdOut(process->program() + " " + process->arguments().join(" ")
                            + " was finished");
        logConsole->writeResult(exitCode, exitStatus, exitCode);
    }
    this->close();
}

void FortschrittDialog::keyPressEvent(QKeyEvent *event)
{
    if(event->key() == Qt::Key_Escape){
        // ignorieren
    }
}

void FortschrittDialog::setShowCancelButton(bool show)
{
    if( show && active){
        ui->cancelButton->show();
    }
    else {
        ui->cancelButton->hide();
    }
}

void FortschrittDialog::on_details_toggled(bool checked)
{
    *details = checked;
}

void FortschrittDialog::on_cancelButton_clicked()
{
    if(active){
        killLinboCmd();
    }
}
