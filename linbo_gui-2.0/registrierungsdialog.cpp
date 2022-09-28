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
}

RegistrierungsDialog::~RegistrierungsDialog()
{
    delete ui;
}

RegistrierungsDialog::RegistrierungsDialog(  QWidget* parent, QString& roomName, QString& clientName,
                                     QString& clientGroup) :
    QDialog(parent), ui(new Ui::RegistrierungsDialog)
{
  ui->setupUi(this);

  ui->roomName->setText(roomName);
  ui->clientName->setText(clientName);
  ui->clientGroup->setText(clientGroup);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

}

void RegistrierungsDialog::accept()
{
    QString *roomName = new QString(ui->roomName->text());
    QString *clientName = new QString(ui->clientName->text());
    QString *clientGroup = new QString(ui->clientGroup->text());

    emit(finished(*roomName, *clientName, *clientGroup));
    delete roomName;
    delete clientName;
    delete clientGroup;
    close();
}
