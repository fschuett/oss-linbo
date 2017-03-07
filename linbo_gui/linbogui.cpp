#include <vector>

#include <QMessageBox>
#include <QDebug>
#include <qfile.h>
#include <qtextstream.h>
#include <qobject.h>
#include <qtimer.h>

#include "linbooswidget.h"

#include "linbogui.h"
#include "ui_linbogui.h"
#include "registrierungsdialog.h"
#include "configuration.h"
#include "command.h"
#include "linboConsole.h"
#include "fortschrittdialog.h"
#include "registrierungsdialog.h"
#include "linboimagewidget.h"
#include "login.h"
#include "linboImageSelector.h"
#include "linboImageUpload.h"
#include "aktion.h"
#include "downloadtype.h"
#include "image_description.h"
#include "linboInfoBrowser.h"
#include "linboMulticastBox.h"
#include "autostart.h"
#include "linboremote.h"

LinboGUI::LinboGUI(QWidget *parent): QMainWindow(parent),
    conf(),command(), process(new QProcess(this)),
    logConsole(new linboLogConsole),batteryTimer(new QTimer(this)),
    remoteTimer(new QTimer(this)),
    ui(new Ui::LinboGUI)
{
    ui->setupUi(this);
    conf = new Configuration();
    command = new Command(conf);
    
    showMaximized();

    details = false;

    // reset root - we're an user now
    root = false;
    // automatic logout after roottimeout;
    roottimeout = 600;

    // we want to see icons
    withicons = true;

    // show command output on LINBO console
    outputvisible = true;

    // first "last visited" tab is start tab
    preTab = 0;

    // logfilepath
    logfilepath = QString("/tmp/linbo.log");

    // we can set this now since our globals have been read
    logConsole->setLinboLogConsole( conf->config.get_consolefontcolorstdout(),
                                    conf->config.get_consolefontcolorstderr(),
                                    ui->log, logfilepath);

    showInfos();

    connect(batteryTimer, SIGNAL(timeout()), this, SLOT(showBatteryInfo()));
    batteryTimer->start(10000);

    showOSs();

    showImages();

    ui->systeme->setCurrentIndex(0);

    //process autostart
    autostartnr = -1;
    for(unsigned int osnr=0;osnr < conf->elements.size() && autostartnr < 0;osnr++){
        os_item* os = &conf->elements.at(osnr);
        for(unsigned int imgnr=0;imgnr < os->image_history.size() && autostartnr < 0; imgnr++ ){
            image_item* img = &os->image_history.at(imgnr);
            if(img->get_autostart() && img->get_autostarttimeout() != 0){
                autostartnr = osnr;
                autostartos = os->get_name();
                autostarttimeout = img->get_autostarttimeout();
            }
        }
    }
    //check for running remote commands
    showRemoteCommand();
    connect(remoteTimer, SIGNAL(timeout()), this, SLOT(showRemoteCommand()));
    remoteTimer->start(2000);
    //process linbocmds
    if(conf->getCommandLine().getLinbocmd() != NULL){
        qDebug() << "Found linbocmd(s), starting 'doWrapperCommands'";
        QTimer::singleShot(500, this, SLOT(doWrapperCommands()));
    }
    else if(autostartnr > -1){
        QTimer::singleShot(500, this, SLOT(doAutostartDialog()));
    }
}

LinboGUI::~LinboGUI()
{
    delete ui;
}

bool LinboGUI::isRoot() const {
    return root;
}

void LinboGUI::showImagingTab() {
    ui->systeme->setCurrentIndex( ADMINTAB );
}

void LinboGUI::readFromStdout()
{
    if( outputvisible ) {
        logConsole->writeStdOut( process->readAllStandardOutput() );
    }
}

void LinboGUI::readFromStderr()
{
    if( outputvisible ) {
        logConsole->writeStdErr( process->readAllStandardError() );
    }
}



bool LinboGUI::isAdminTab(int tabIndex) {
    return (tabIndex == ADMINTAB);
}

bool LinboGUI::isLogTab(int tabIndex) {
    return (tabIndex == LOGTAB);
}

globals LinboGUI::config()
{
    return conf->config;
}

void LinboGUI::showRemoteCommand()
{
    if(!LinboRemote::is_running()){
        return;
    }
    QStringList infos = LinboRemote::get_commandline();
    if(infos.isEmpty()){
        return;
    }
    progress = new FortschrittDialog( this, false, &infos, logConsole,
                                      ( infos.length() > 2 ?
                                        QString("Linbo-Remote: "+infos.at(1)+" "+infos.at(2)) :
                                        QString("Linbo-Remote: ...")
                                      ), Aktion::None, &details );
    progress->setShowCancelButton( false );
    progress->exec();
}

void LinboGUI::showBatteryInfo()
{
    ui->battery->setText(QString("Batterie: ") + command->doSimpleCommand(QString("battery")) + QString(" %"));
}

void LinboGUI::showInfos()
{
    ui->rechner->setText(QString("Host: ") + command->doSimpleCommand(QString("hostname")));
    ui->gruppe->setText(QString("Gruppe: ") + conf->config.get_hostgroup());
    ui->ip->setText(QString("IP: ") + command->doSimpleCommand(QString("ip")));
    ui->mac->setText(QString("MAC: ") + command->doSimpleCommand(QString("mac")));
    showBatteryInfo();
    QString cpu = command->doSimpleCommand(QString("cpu"));
    cpu.remove(QRegExp("[\r\n].*$"));
    ui->cpu->setText(QString("CPU: ") + cpu);
    ui->ram->setText(QString("RAM: ") + command->doSimpleCommand(QString("memory")));
    ui->cache->setText(QString("Cache: ") + command->doSimpleCommand(QString("size"),conf->config.get_cache()));
    ui->hd->setText(QString("HD: ") + command->doSimpleCommand(QString("size"),conf->config.get_hd()));

    ui->version->setText(command->doSimpleCommand(QString("version")) + QString(" auf Server ") + conf->config.get_server());

}

void LinboGUI::on_halt_clicked()
{
    logConsole->writeStdOut( QString("shutdown entered") );
    QStringList cmd;
    cmd.clear();
    cmd = QStringList("busybox");
    cmd.append("poweroff");
    doCommand( cmd, false, QString("Rechner fährt herunter") );
}

void LinboGUI::on_reboot_clicked()
{
    logConsole->writeStdOut( QString("reboot entered") );
    QStringList cmd;
    cmd.clear();
    cmd = QStringList("busybox");
    cmd.append("reboot");
    doCommand( cmd, false, QString("Rechner startet neu") );
}

void LinboGUI::on_update_clicked()
{
      logConsole->writeStdOut( QString("update entered") );
      QStringList cmd = command->mklinboupdatecommand();
      doCommand( cmd, false, QString("Linbo wird aktualisiert"), Aktion::None, &details );
}

void LinboGUI::on_systeme_currentChanged(int index)
{
    if( !isRoot() ) {
        if( isAdminTab(index)) {
            // if our partition button is disabled, there is a linbo_cmd running
            if( process->state() != QProcess::Running ) {
                ui->systeme->setCurrentIndex( preTab );
                Login *dlg = new Login();
                connect(dlg, SIGNAL(acceptLogin(QString)), this, SLOT(performLogin(QString)));
                dlg->exec();
            }
            else {
                ui->systeme->setCurrentIndex( preTab );
            }
        }
    }
    if( (ui->systeme->currentIndex() != ADMINTAB && ui->systeme->currentIndex() != LOGTAB)  )
        preTab = ui->systeme->currentIndex();
}

void LinboGUI::on_doregister_clicked()
{
    // Die vorgeschlagenen Daten fuer die Rechneraufnahme lesen und anzeigen
    QStringList registerDataList;
    command->doSimpleCommand(command->mkpreregistercommand().join(" "));

    char line[1024];
    ifstream newdata;
    QString registerData;
    newdata.open("/tmp/newregister", ios::in);
    if (newdata.is_open()) {
        newdata.getline(line,1024,'\n');
        registerData = QString::fromUtf8( line, -1 ).trimmed();
        newdata.close();
        registerDataList = registerData.split(',');
    }

    RegistrierungsDialog *regdlg;
    if( registerDataList.size() >= 4 ){
        regdlg = new RegistrierungsDialog( this, registerDataList[0], registerDataList[1],
                registerDataList[2], registerDataList[3]);
    }
    else {
        regdlg = new RegistrierungsDialog( this );
    }
    connect(regdlg,SIGNAL(finished(QString&, QString&, QString&, QString&)),
            this,SLOT(do_register(QString&, QString&, QString&, QString&)));
    regdlg->exec();
}

void LinboGUI::do_register(QString& roomName, QString& clientName, QString& ipAddress, QString& clientGroup)
{
    doCommand(command->mkregistercommand(roomName, clientName, ipAddress, clientGroup), true, QString("Registrieren"), Aktion::None, &details);
}

void LinboGUI::showOSs()
{
    const int MAXOSCOLUMN = 1;
    int row = 0;
    int col = 0;
    for(std::vector<os_item>::iterator it = conf->elements.begin(); it != conf->elements.end(); ++it) {
        LinboOSWidget *os = new LinboOSWidget(ui->osarea, (MAXOSCOLUMN+1)*row+col, &*it);
        connect(os, &LinboOSWidget::doStart, this, &LinboGUI::doStart);
        connect(os, &LinboOSWidget::doSync, this, &LinboGUI::doSync);
        connect(os, &LinboOSWidget::doNew, this, &LinboGUI::doNew);
        connect(os, &LinboOSWidget::doInfo, this, &LinboGUI::doInfoDialog);
        ui->osareaLayout->addWidget(os, row, col);
        os->show();
        col++;
        if(col > MAXOSCOLUMN){
            col = 0;
            row++;
        }
    }
    ui->osarea->adjustSize();
}

void LinboGUI::showImages()
{
    int row = 0;
    for(std::vector<os_item>::iterator it = conf->elements.begin(); it != conf->elements.end(); ++it) {
        LinboImageWidget *img = new LinboImageWidget(ui->imagearea, row, &*it);
        connect(img, &LinboImageWidget::doCreate, this, &LinboGUI::doCreateDialog);
        connect(img, &LinboImageWidget::doUpload, this, &LinboGUI::doUploadDialog);
        ui->imageareaLayout->addWidget(img, row, 0);
        img->show();
        row++;
    }
    ui->imagearea->adjustSize();
}

void LinboGUI::performLogin(QString passwd)
{
    if( command->doAuthenticateCommand( passwd ) ) {
        root = true;
        ui->cbTimeout->setEnabled( true );
        ui->cbTimeout->setChecked( true );
        ui->timeoutCounter->setEnabled( true );
        ui->timeoutCounter->display( roottimeout );
        logoutTimer = this->startTimer( 1000 );
        ui->systeme->setCurrentIndex( ADMINTAB );
    }
    else {
        QMessageBox::information( this, QString("Login"),
                                  QString("Das angegebene Passwort ist falsch."),
                                  QMessageBox::Ok);
    }
}

void LinboGUI::performLogout()
{
    if( logoutTimer != 0 ){
        this->killTimer( logoutTimer );
        logoutTimer = 0;
    }
    root = false;
    command->clearPassword();
    ui->cbTimeout->setEnabled( false );
    ui->timeoutCounter->setEnabled( false );
    ui->timeoutCounter->display( 0 );
    if( ui->systeme->currentIndex() == ADMINTAB ) {
        ui->systeme->setCurrentIndex(0);
    }
}

void LinboGUI::on_logout_clicked()
{
    performLogout();
}

void LinboGUI::timerEvent(QTimerEvent *event)
{
    if( event->timerId() == logoutTimer ) {
        int time = ui->timeoutCounter->intValue();
        if( --time <= 0 ){
            performLogout();
        }
        else {
            ui->timeoutCounter->display( time );
        }
    }
}

void LinboGUI::on_cbTimeout_toggled(bool checked)
{
    ui->timeoutCounter->setEnabled( checked );
    if( checked ) {
        ui->timeoutCounter->display( roottimeout );
        logoutTimer = this->startTimer( 1000 );
    }
    else {
        if( logoutTimer != 0 ) {
            this->killTimer( logoutTimer );
            logoutTimer = 0;
        }
    }
}

void LinboGUI::doWrapperCommands()
{
    vector<QStringList> cmds =  command->parseWrapperCommands(conf->getCommandLine().getLinbocmd());
    for(vector<QStringList>::iterator it = cmds.begin();it != cmds.end();++it){
        QStringList cmd = *it;
        qDebug() << "doWrapperCommand: " << cmd.join("@") <<"\n";
        doCommand(cmd, false, cmd.at(1), Aktion::None, &details);
    }
    if(autostartnr > -1){
        QTimer::singleShot(500, this, SLOT(doAutostartDialog()));
    }
}

int LinboGUI::doCommand(const QStringList& command, bool interruptible, const QString& titel, Aktion aktion, bool* details)
{
    QStringList *cmd = new QStringList(command);
    progress = new FortschrittDialog( this, true, cmd, logConsole, titel, aktion, details );
    progress->setShowCancelButton( interruptible );
    return progress->exec();
}

void LinboGUI::on_console_clicked()
{
    //TODO
    linboConsole console( this );
    console.exec();
}

void LinboGUI::doAutostart()
{

    doCommand(command->mkstartcommand(autostartnr), false, QString("Automatischer Start"), Aktion::None, &details);
}

void LinboGUI::doStart(int nr)
{
    doCommand(command->mkstartcommand(nr), false, QString("Start"), Aktion::None, &details);
}

void LinboGUI::doSync(int nr)
{
    doCommand(command->mksyncstartcommand(nr, -1, false), false, QString("Sync & Start"), Aktion::None, &details);
}

void LinboGUI::doNew(int nr)
{
    doCommand(command->mksyncstartcommand(nr, -1, true), false, QString("Neu & Start"), Aktion::None, &details);
}

void LinboGUI::on_initcache_clicked()
{
    linboMulticastBox* dlg = new linboMulticastBox(this, conf->config.get_autoformat(), conf->config.get_downloadtype());
    connect(dlg, &linboMulticastBox::finished, this, &LinboGUI::doInitCache);
    dlg->exec();
}

void LinboGUI::on_partition_clicked()
{
    doCommand(command->mkpartitioncommand(), false, QString("Partitionieren"), Aktion::None, &details);
}

void LinboGUI::on_setup_clicked()
{
    doCommand( command->mkpartitioncommand(), true, QString("Einrichten - Partitionieren"), Aktion::None, &details);
    doCommand( command->mkcacheinitcommand(false, conf->config.get_downloadtype()), true, QString("Einrichten - Cache aktualisieren"), Aktion::None, &details);
    for(unsigned int osnr = 0;osnr < conf->elements.size(); osnr++){
        doCommand( command->mksynccommand(osnr), true, QString("Einrichten - Synchronisieren OS Nr."+osnr), Aktion::None, &details);
    }
    doCommand( command->mkstartcommand(0), true, QString("Einrichten - Start OS Nr.1"), Aktion::None, &details);
}

void LinboGUI::doAutostartDialog()
{
    Autostart* dlg = new Autostart( this, autostarttimeout, QString("Autostart " + autostartos));
    connect( dlg, &Autostart::accepted, this, &LinboGUI::doAutostart);
    dlg->exec();
}

void LinboGUI::doInfoDialog(int nr)
{
    QString filename = conf->elements[nr].image_history[conf->elements[nr].find_current_image()].get_image();
    QString description = QString("");
    QFile* file = new QFile( filename );
    // read content
    if( !file->open( QIODevice::ReadOnly ) ) {
      logConsole->writeStdErr( QString("Keine passende Beschreibung im Cache.") );
    }
    else {
      QTextStream ts( file );
      description = ts.readAll();
      file->close();
    }

    linboInfoBrowser* dlg = new linboInfoBrowser( this, filename, description, !isRoot());
    dlg->exec();
}

void LinboGUI::doCreateDialog(int nr)
{
    vector<image_item>* history = &conf->elements[nr].image_history;
    linboImageSelector* dlg = new linboImageSelector( this, nr, history, command );
    connect(dlg,SIGNAL(finished(int, const QString&, const QString&, bool, bool, Aktion)),
            this, SLOT(doCreate(int, const QString&, const QString&, bool, bool, Aktion)));
    dlg->exec();
}

void LinboGUI::doUploadDialog(int nr)
{
    vector<image_item> history = conf->elements[nr].image_history;
    linboImageUpload* dlg = new linboImageUpload( this, &history );
    connect(dlg, SIGNAL(finished(const QString&, Aktion)),
            this, SLOT(doUpload(const QString&, Aktion)));
    dlg->exec();
}

void LinboGUI::doCreate(int nr, const QString& imageName, const QString& description, bool isnew, bool upload, Aktion aktion)
{
    QString baseImage = imageName.left(imageName.lastIndexOf(".")) + Command::BASEIMGEXT;
    QString title = QString("Image erstellen");
    if( upload ){
        title += "(und hochladen)";
    }
    doCommand(command->mkcreatecommand(nr, imageName, baseImage), true, title, aktion, &details);
    if(isnew){
        os_item os = conf->elements[nr];
        image_item new_image;
        os.image_history.push_back(new_image);
    }

    QString tmpName = Command::TMPDIR + imageName + Command::DESCEXT;
    QString destination = imageName + Command::DESCEXT;

    QFile* file = new QFile( tmpName );
    if ( !file->open( QIODevice::WriteOnly ) ) {
        logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
    } else {
        QTextStream ts( file );
        ts << description;
        file->flush();
        file->close();
    }
    delete file;
    command->doWritefileCommand(tmpName, destination);

    if( upload ){
        doCommand(command->mkuploadcommand(imageName), true, QString("Image hochladen"), aktion, &details);
    }
    if(aktion == Aktion::Reboot)
        system("busybox reboot");
    else if(aktion == Aktion::Shutdown)
        system("busybox shutdown");
}

void LinboGUI::doUpload(const QString &imageName, Aktion aktion)
{
    doCommand( command->mkuploadcommand( imageName), true, QString("Image hochladen"), aktion, &details);

    if (aktion == Aktion::Shutdown) {
        system("busybox poweroff");
    } else if (aktion == Aktion::Reboot) {
        system("busybox reboot");
    }
}

void LinboGUI::doInfo(const QString& filename, const QString& description)
{
    QString tmpname = command->TMPDIR + filename;
    QFile* file = new QFile( tmpname );
    if ( !file->open( QIODevice::WriteOnly ) ) {
        logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
    } else {
        QTextStream ts( file );
        ts << description;
        file->flush();
        file->close();
    }
    delete file;

    command->doWritefileCommand(tmpname, filename);
}

void LinboGUI::doInitCache(bool formatCache, DownloadType type)
{
    doCommand( command->mkcacheinitcommand(formatCache, type), false, QString("Cache aktualisieren"), Aktion::None, &details);
}
