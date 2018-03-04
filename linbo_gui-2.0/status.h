#ifndef STATUS_H
#define STATUS_H
#include <QObject>

class Status : public QObject
{
    Q_OBJECT
    bool online; //Es besteht eine Verbindung zum Netzwerk.
    bool registriert; //Der Rechner ist bereits registriert.
    bool hd; //Eine 1.Festplatte ist vorhanden.
    bool partitioniert; //Die 1. Festplatte ist partitioniert nach start.conf.
    bool cache_formatiert; //Die Cache-Partition ist formatiert.
    bool linbo_aktualisiert; //Die Aktualisierung wurde bereits durchgeführt.

public:
    explicit Status(QObject *parent = 0);
    void setOnline(bool wert);
    void setRegistriert(bool wert);
    void setHd(bool wert);
    void setPartitioniert(bool wert);
    void setCacheFormatiert(bool wert);
    void setLinboAktualisiert(bool wert);

signals:
    void statusChanged();
    void onlineChanged(bool wert);
    void registriertChanged(bool wert);
    void hdChanged(bool wert);
    void partitioniertChanged(bool wert);
    void cacheFormatiert(bool wert);
    void linboAktualisiert(bool wert);

public slots:
};

#endif // STATUS_H
