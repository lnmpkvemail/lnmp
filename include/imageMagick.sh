#!/bin/bash

Install_ImageMagic()
{
    echo "====== Installing ImageMagic ======"
    Press_Install

    sed -i '/imagick.so/d' /usr/local/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}imagick.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/imagemagick/${ImageMagick_Ver}.tar.gz ${ImageMagick_Ver}.tar.gz

    Tar_Cd ${ImageMagick_Ver}.tar.gz ${ImageMagick_Ver}
    ./configure --prefix=/usr/local/imagemagick
    make && make install
    cd ../
    rm -rf ${cur_dir}/src/${ImageMagick_Ver}

    if  echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.';then
        Download_Files ${Download_Mirror}/web/imagick/imagick-3.1.2.tgz imagick-3.1.2.tgz
        Tar_Cd imagick-3.1.2.tgz imagick-3.1.2
    else
        Download_Files ${Download_Mirror}/web/imagick/${Imagick_Ver}.tgz ${Imagick_Ver}.tgz
        Tar_Cd ${Imagick_Ver}.tgz ${Imagick_Ver}
    fi
    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
    make && make install
    cd ../

    sed -i '/the dl()/i\
extension = "imagick.so"' /usr/local/php/etc/php.ini

    if [ -s "${zend_ext}" ] && [ -s /usr/local/imagemagick/bin/convert ]; then
        Restart_PHP
        echo "====== ImageMagick install completed ======"
        echo "ImageMagick installed successfully, enjoy it!"
    else
        sed -i '/imagick.so/d' /usr/local/php/etc/php.ini
        echo "imagick install failed!"
    fi
}

Uninstall_ImageMagick()
{
    echo "You will uninstall ImageMagick..."
    Press_Start
    sed -i '/imagick.so/d' /usr/local/php/etc/php.ini
    echo "Delete ImageMagick directory..."
    rm -rf /usr/local/imagemagick
    Restart_PHP
    echo "Uninstall ImageMagick completed."
}
