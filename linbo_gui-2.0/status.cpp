#include "status.h"

Status::Status(QObject *parent) : QObject(parent),
    online(false),registriert(false),hd(false),partitioniert(false),
    cache_formatiert(false),linbo_aktualisiert(false)
{

}

void Status::setOnline(bool wert)
{
    if(online != wert)
    {
        wert = online;
        onlineChanged(online);
        statusChanged();
    }
}

void Status::setRegistriert(bool wert)
{
    if(registriert != wert)
    {
        wert = registriert;
        registriertChanged(registriert);
        statusChanged();
    }
}

void Status::setHd(bool wert)
{
    if(hd != wert)
    {
        hd = wert;
        hdChanged(hd);
        statusChanged();
    }
}

void Status::setPartitioniert(bool wert)
{
    if(partitioniert != wert)
    {
        partitioniert = wert;
        partitioniertChanged(partitioniert);
        statusChanged();
    }
}

void Status::setCacheFormatiert(bool wert)
{
    if(cache_formatiert != wert)
    {
        cache_formatiert = wert;
        cacheFormatiert(cache_formatiert);
        statusChanged();
    }
}

void Status::setLinboAktualisiert(bool wert)
{
    if(linbo_aktualisiert != wert)
    {
        linbo_aktualisiert = wert;
        linboAktualisiert(linbo_aktualisiert);
        statusChanged();
    }
}
