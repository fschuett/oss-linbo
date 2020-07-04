#include <qregexp.h>
#include <QRegExpValidator>

#include "registrierungsdialog.h"
#include "ui_registrierungsdialog.h"

#include "ip4validator.h"

RegistrierungsDialog::RegistrierungsDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::RegistrierungsDialog)
{
    ui->setupUi(this);
    ui->ipAddress->setValidator(new IP4Validator(this));
    ui->ipAddress->setInputMask("000.000.000.000");
    ui->ipAddress2->setValidator(new IP4Validator(this));
    ui->ipAddress2->setInputMask("000.000.000.000");
}

RegistrierungsDialog::~RegistrierungsDialog()
{
    delete ui;
}

RegistrierungsDialog::RegistrierungsDialog(  QWidget* parent, QString& roomName, QString& clientName,
                                     QString& macAddress, QString& ipAddress,
                                     QString& macAddress2, QString& ipAddress2, QString& clientGroup) :
    QDialog(parent), ui(new Ui::RegistrierungsDialog)
{
  ui->setupUi(this);
  ui->ipAddress->setValidator(new IP4Validator(this));
  ui->ipAddress->setInputMask("000.000.000.000");
  ui->ipAddress2->setValidator(new IP4Validator(this));
  ui->ipAddress2->setInputMask("000.000.000.000");

  ui->roomName->setText(roomName);
  ui->clientName->setText(clientName);
  ui->macAddress->setText(macAddress);
  ui->ipAddress->setText(ipAddress);
  ui->macAddress2->setText(macAddress2);
  ui->ipAddress2->setText(ipAddress2);
  ui->clientGroup->setText(clientGroup);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

}

void RegistrierungsDialog::accept()
{
    QString *roomName = new QString(ui->roomName->text());
    QString *clientName = new QString(ui->clientName->text());
    QString *ipAddress = new QString(ui->ipAddress->text());
    QString *ipAddress2 = new QString(ui->ipAddress2->text());
    QString *clientGroup = new QString(ui->clientGroup->text());

    emit(finished(*roomName, *clientName, *ipAddress, *ipAddress2, *clientGroup));
    delete roomName;
    delete clientName;
    delete ipAddress;
    delete ipAddress2;
    delete clientGroup;
    close();
}
