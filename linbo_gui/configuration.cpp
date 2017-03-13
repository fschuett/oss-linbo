#include "configuration.h"

#include <fstream>
#include <iostream>
#include <unistd.h>

#include <qstring.h>
#include <qstringlist.h>
#include <qdebug.h>

#include "image_description.h"
#include "commandline.h"

void Configuration::read_qstring( QString& tmp ) {
    char line[500];
    input.getline(line,500,'\n');
    tmp = QString::fromUtf8( line, -1 ).trimmed();
}

void Configuration::quote(QString& unquoted){
    if(unquoted == NULL)
        return;
    if(! unquoted.contains(" "))
        return;
    unquoted = (unquoted.startsWith("\"")? QString("") : QString("\""))
           + unquoted
           + (unquoted.endsWith("\"")? QString("") : QString("\""));
}

void Configuration::read_bool(bool& tmp) {
    char line[500];
    input.getline(line,500,'\n');
    tmp = atoi( line );
}

// Return true unless beginning of new section '[' is found.
bool Configuration::read_pair(QString& key, QString& value) {
    char line[1024];
    if(input.peek() == '[') return false; // Next section found.
    input.getline(line,1024,'\n');
    QString s = QString::fromUtf8( line, -1 ).trimmed();
    key = s.section("=",0,0).trimmed().toLower();
    if(s.startsWith("#")||key.isEmpty()) {
        key = QString(""); value = QString("");
    } else {
        value=s.section("=",1).section("#",0,0).trimmed();
    }
    return true;
}

bool Configuration::toBool(const QString& value) {
    if(value.startsWith("yes",Qt::CaseInsensitive)) return true;
    if(value.startsWith("true",Qt::CaseInsensitive)) return true;
    if(value.startsWith("enable",Qt::CaseInsensitive)) return true;
    return false;
}

// value: 1basiert, ret: 0basiert
int Configuration::toPartitionNr(const QString& value, bool *ok) {
    int partnr = value.toInt(ok);
    if(!ok)
        return -1;
    if( partnr < 1 || (uint)partnr > partitions.size() ){
        *ok = false;
        return -1;
    }
    return (partnr-1);
}

// value: 1basiert, ret: 0basiert
int Configuration::toOSNr(const QString& value, bool *ok) {
    int osnr = value.toInt(ok);
    if(!ok)
        return -1;
    if( osnr < 1 || (uint)osnr > elements.size() ){
        *ok = false;
        return -1;
    }
    return (osnr-1);
}

void Configuration::read_os( os_item& tmp_os, image_item& tmp_image ) {
    QString key, value;
    while(!input.eof() && read_pair(key, value)) {
        if(key.compare("name") == 0) tmp_os.set_name(value);
        else if(key.compare("description") == 0)  tmp_image.set_description(value);
        else if(key.compare("version") == 0)      tmp_image.set_version(value);
        else if(key.compare("iconname") == 0)     tmp_os.set_iconname(value);
        else if(key.compare("image") == 0)        tmp_image.set_image(value);
        else if(key.compare("baseimage") == 0)    tmp_os.set_baseimage(value);
        else if(key.compare("boot") == 0)         tmp_os.set_boot(value);
        else if(key.compare("root") == 0)         tmp_os.set_root(value);
        else if(key.compare("kernel") == 0)       tmp_image.set_kernel(value);
        else if(key.compare("initrd") == 0)       tmp_image.set_initrd(value);
        else if(key.compare("append") == 0) {
            quote(value);
            tmp_image.set_append(value);
        }
        else if(key.compare("syncenabled") == 0)  tmp_image.set_syncbutton(toBool(value));
        else if(key.compare("startenabled") == 0) tmp_image.set_startbutton(toBool(value));
        else if((key.compare("remotesyncenabled") == 0) || (key.compare("newenabled") == 0))   tmp_image.set_newbutton(toBool(value));
        else if(key.compare("defaultaction") == 0) tmp_image.set_defaultaction(value);
        else if(key.compare("autostart") == 0)   tmp_image.set_autostart(toBool(value));
        else if(key.compare("autostarttimeout") == 0)   tmp_image.set_autostarttimeout(value.toInt());
        else if(key.compare("hidden") == 0)   tmp_image.set_hidden(toBool(value));
    }
    if(tmp_image.get_image().isEmpty())
        tmp_image.set_image(tmp_os.get_baseimage());
}

void Configuration::read_partition( diskpartition& p ) {
    QString key, value;
    while(!input.eof() && read_pair(key, value)) {
        if(key.compare("dev") == 0) p.set_dev(value);
        else if(key.compare("size") == 0)  p.set_size(value);
        else if(key.compare("id") == 0)  p.set_id(value);
        else if(key.compare("fstype") == 0)  p.set_fstype(value);
        else if(key.compare("label") == 0) p.set_label(value);
        else if(key.startsWith("bootable", Qt::CaseInsensitive))  p.set_bootable(toBool(value));
    }
}

void Configuration::read_globals() {
    QString key, value;
    while(!input.eof() && read_pair(key, value)) {
        if(key.compare("server") == 0) config.set_server(value);
        else if(key.compare("cache") == 0)  config.set_cache(value);
        else if(key.compare("roottimeout") == 0)  config.set_roottimeout((unsigned int)value.toInt());
        else if(key.compare("group") == 0)  config.set_hostgroup(value);
        else if(key.compare("kerneloptions") == 0) config.set_kerneloptions(value);
        else if(key.compare("systemtype") == 0) config.set_systemtype(value);
        else if(key.compare("autopartition") == 0) config.set_autopartition(toBool(value));
        else if(key.compare("autoinitcache") == 0) config.set_autoinitcache(toBool(value));
        else if(key.compare("backgroundfontcolor") == 0) config.set_backgroundfontcolor(value);
        else if(key.compare("consolefontcolorstdout") == 0) config.set_consolefontcolorstdout(value);
        else if(key.compare("consolefontcolorstderr") == 0) config.set_consolefontcolorstderr(value);
        else if(key.compare("usemulticast") == 0) {
            if( (unsigned int)value.toInt() == 0 )
                config.set_downloadtype("rsync");
            else
                config.set_downloadtype("multicast");
        }
        else if(key.compare("downloadtype") == 0) config.set_downloadtype(value);
        else if(key.compare("autoformat") == 0) config.set_autoformat(toBool(value));
    }
}

bool Configuration::validPartition(const QString &partition)
{
    for(vector<diskpartition>::iterator it = partitions.begin();it < partitions.end();++it){
        if((*it).get_dev().compare(partition) == 0)
            return true;
    }
    return false;
}

void Configuration::init(const char name[])
{
    char filename[FILENAME_MAX];
    getcwd(filename,sizeof(filename));
    strcat(filename, "/");
    strcat(filename, name);
    input.open( filename, ios_base::in );
    if( input.fail() ){
        qWarning() << "Die Datei " << filename << " konnte nicht geöffnet werden.";
        return;
    }

    QString tmp_qstring;

    while( !input.eof() ) {
        // entry in start tab
        read_qstring(tmp_qstring);
        if ( tmp_qstring.startsWith("#") || tmp_qstring.isEmpty() ) continue;

        tmp_qstring = tmp_qstring.section("#",0,0).trimmed(); // Strip comment
        if(tmp_qstring.toLower().compare("[os]") == 0) {
            os_item tmp_os;
            image_item tmp_image;
            read_os(tmp_os, tmp_image);
            if(!tmp_os.get_name().isEmpty()) {
                // check if this is an additional/incremental image for an existing OS
                unsigned int i; // Being checked later.
                for(i = 0; i < elements.size(); i++ ) {
                    if(tmp_os.get_name().toLower().compare(elements[i].get_name().toLower()) == 0) {
                        elements[i].image_history.push_back(tmp_image); break;
                    }
                }
                if(i==elements.size()) { // Not included yet -> new image
                    tmp_os.image_history.push_back(tmp_image);
                    elements.push_back(tmp_os);
                }
            }
        } else if(tmp_qstring.toLower().compare("[linbo]") == 0) {
            read_globals();
        } else if(tmp_qstring.toLower().compare("[partition]") == 0) {
            diskpartition tmp_partition;
            read_partition(tmp_partition);
            if(!tmp_partition.get_dev().isEmpty()) {
                partitions.push_back(tmp_partition);
            }
        }
    }
    input.close();
}

void Configuration::disable_autostart()
{
    for(std::vector<os_item>::iterator it = this->elements.begin(); it != this->elements.end(); ++it) {
        for(std::vector<image_item>::iterator iit = (*it).image_history.begin(); iit != (*it).image_history.end(); ++iit) {
            (*iit).set_autostart(false);
        }
    }
}

Configuration::Configuration(): commandline()
{
    if( commandline.getExtraConf() != NULL ){
        if(commandline.getConfPartition() != NULL && validPartition(commandline.getConfPartition())){
            system("mount "+commandline.getConfPartition().toLocal8Bit()+" /mnt");
            QString path = "/mnt";
            if(!commandline.getExtraConf().startsWith("/"))
                path += "/";
            path += commandline.getExtraConf();
            init(path.toLocal8Bit());
            system("umount "+commandline.getConfPartition().toLocal8Bit());
        }
        else {
            init(commandline.getExtraConf().toLocal8Bit());
        }
    }
    else {
        init("start.conf");
        if(commandline.getCache() != NULL){
            this->config.set_cache(commandline.getCache());
        }
    }
    if( commandline.getServer() != NULL){
        this->config.set_server(commandline.getServer());
    }
    if( commandline.validAutostart() ){
        disable_autostart();
        if( commandline.getAutostart() > -1 && commandline.getAutostart() < (int)elements.size()){
            os_item* os = &this->elements.at(commandline.getAutostart());
            image_item* img = &os->image_history.at(os->find_current_image());
            img->set_autostart(true);
        }
    }
    if( commandline.noAuto() ){
        disable_autostart();
        this->config.set_autoformat(false);
        this->config.set_autoinitcache(false);
        this->config.set_autopartition(false);
    }
    if( commandline.noButtons() ){
        for(std::vector<os_item>::iterator it = this->elements.begin(); it != this->elements.end(); ++it) {
            for(std::vector<image_item>::iterator iit = (*it).image_history.begin(); iit != (*it).image_history.end(); ++iit) {
                (*iit).set_newbutton(false);
                (*iit).set_startbutton(false);
                (*iit).set_syncbutton(false);
                (*iit).set_autostart(false);
                (*iit).set_hidden(true);
            }
        }
    }
}

Configuration::~Configuration()
{

}

CommandLine Configuration::getCommandLine()
{
    return commandline;
}
