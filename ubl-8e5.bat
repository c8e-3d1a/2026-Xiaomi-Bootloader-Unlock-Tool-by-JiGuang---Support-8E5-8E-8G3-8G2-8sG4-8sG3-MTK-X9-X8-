@echo off
chcp 65001
chcp 936 >nul
setlocal enabledelayedexpansion
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
title JiGuang_8EliteGen5(SM8850)_BootLoader_UNLOCKING TOOL
color 0A
echo ==================================================
echo     Welcome JiGuang BootLoader_UNLOCKING TOOL
echo     作者：酷安 @AC极光_Official
echo     解锁文件：酷安@道可道official
echo     QQ:2130275658
echo     team:626291244
echo ==================================================
echo Make sure:
echo  1. 手机已进入 usb调试模式并连接电脑
echo  2. 电脑已安装 adb 和 fastboot 驱动
pause
:: 检查 adb 和 fastboot 是否可用
where adb >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到adb，检查是否解压完整！
    pause
)
where fastboot >nul 2>nul
if errorlevel 1 (
    echo [错误] 未找到fastboot，请安装并添加到 PATH。
    pause
    exit /b 1
)
echo=================================================================
echo \      /\      /                   .
echo  \    /  \    /  /———l   \/ \/——\  /  \/——\  /———/
echo   \  /    \  /  /    l   /  /   /  /  /   /  /   /
echo    \/      \/   \_____\  /  /   /  /  /   /  /___/
echo                                                  /
echo                                              ___/
echo   1.再次强调：解锁 BL 会清空所有数据！            
echo   2.如果运行者自身原因导致手机变砖或数据丢失，那就受着
echo   3.如果不会 可以请求群主远程解锁（不免费）
echo   4.未经授权禁止二创、去署名、改成恶意脚本、移植其他机型等！
echo=================================================================
pause
:check_adb
echo [1] 检查设备链接...
adb devices | find " device" >nul
if errorlevel 1 (
    echo [错误] 未检测到设备，请检查驱动和数据线
    pause
    goto check_adb
)
echo 检查型号
for /f "delims=" %%i in ('adb shell getprop ro.product.device') do set "device_code=%%i"
set "product=%device_code:\r=%"
if "%product%"=="pudding" (set "moid=小米17")
if "%product%"=="pandora" (set "moid=小米17Pro")
if "%product%"=="popsicle" (set "moid=小米17ProMax")
if "%product%"=="nezha" (set "moid=小米17Ultra")
if "%product%"=="myron" (set "moid=红米K90ProMax")
if "%product%"=="byron" (set "moid=小米17Max")
if "%product%"=="" (set "moid=")
if "%moid%"=="" (echo 型号识别失败
pause
goto check_adb)
echo 您的型号为%moid%-%product%请确认是否一致
pause
echo ==================================================
echo  文件列表：
echo  1./main/High_Version/%product%/abl.elf
echo  2./main/Unlocking-SM8850.efi
echo  3./main/misc_wipe.img
echo  4./main/High_Version/preload.so
echo ==================================================
:chose
color 0A
echo ==============================
echo      请选择对应版本
echo       1.2月补丁前
echo       2.2月补丁后
echo ==============================
set /p choice=请输入对应数字后回车: 
if "%choice%"=="1" (goto set_Permissive)
:check_adb1
echo 推送abl分区文件 
adb push ./main/High_Version/%product%/abl.elf /data/local/tmp/
if errorlevel 1 (
    echo 推送abl分区文件 [失败] 请确保已经开启并允许调试
    pause
    goto check_adb1
)
:get_root
echo 推送bin文件... 
adb push ./main/High_Version/preload.so /data/local/tmp/preload
if errorlevel 1 (
    echo 推送bin文件 [失败] 请确保已经开启并允许调试
    pause
    goto get_root
)
echo 设置权限为755
adb shell chmod 755 /data/local/tmp/preload
echo 执行宽容...
adb shell LD_PRELOAD=/data/local/tmp/preload /system/bin/true

echo 检查root权限
adb shell su -c "id" | find "uid=0" >nul
if errorlevel 1 (
    echo 未获取到 Root [失败] 
    echo 即将重新获取root
    color 4A
    pause
    goto get_root
) else (
    echo [成功] 已获取 Root 权限
    color 0A
    goto flash_efisp
)
:flash_efisp
if "%product%"=="byron" (
echo 回读abl
adb shell "su -c 'dd if=/dev/block/by-name/abl_a of=/sdcard/abl_a.img bs=4096 conv=fsync'"
adb shell "su -c 'dd if=/dev/block/by-name/abl_b of=/sdcard/abl_b.img bs=4096 conv=fsync'"
timeout /t 1 /nobreak >nul
adb pull /sdcard/abl_a.img ./main/abl_a.img&&adb pull /sdcard/abl_b.img ./main/abl_b.img
)
echo 刷入abl(如果黑屏断联，则上一步宽容失败 重启手机重新打开脚本)
adb shell "su -c 'dd if=/data/local/tmp/abl.elf of=/dev/block/by-name/abl_a bs=4096 conv=fsync'"
timeout /t 1 /nobreak >nul
adb shell "su -c 'dd if=/data/local/tmp/abl.elf of=/dev/block/by-name/abl_b bs=4096 conv=fsync'"
timeout /t 1 /nobreak >nul

if "%product%"=="byron" (
echo 刷入efisp
adb push ./main/Unlocking-byron.efi /data/local/tmp/Unlocking-SM8850.efi
) else (
echo 刷入efisp
adb push ./main/Unlocking-SM8850.efi /data/local/tmp/
)
adb shell "su -c 'dd if=/data/local/tmp/Unlocking-SM8850.efi of=/dev/block/by-name/efisp'"
timeout /t 1 /nobreak >nul
goto flash
:set_Permissive
if "%product%"=="byron" (
echo 选错版本了 滚回去重选！
color 4A
pause
goto chose
)
echo [1] 检查 Fastboot 设备...
fastboot devices | find "fastboot" >nul
if errorlevel 1 (
    echo [错误] 未检测到 Fastboot 设备，请确保手机已进入 Fastboot 模式并连接电脑。
    pause
    goto set_Permissive
) else (echo [成功] 检测到 Fastboot 设备。)

echo [2] 发送 fastboot 指令：设置 selinux 为宽容模式...
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
if errorlevel 1 (
    echo [警告] fastboot oem 命令可能失败，继续尝试启动...
) else (echo [成功] 已发送 selinux 宽容模式指令)

echo 发送 fastboot continue 指令...
fastboot continue
if errorlevel 1 (
    echo [错误] fastboot continue 失败，请检查手机状态。
    pause
    cmd /k
) else (echo [成功] 手机正在重启，请稍候...
 )
echo [3/3] 等待手机启动（约30秒）...
timeout /t 30 /nobreak >nul
:chkdev
echo 请将手机打开USB调试并允许调试
adb devices | find "device" >nul
if errorlevel 1 (
    echo [错误] 未检测到设备，请检查驱动和数据线。
    pause
    goto chkdev
) 
:pushabl 
echo 推送abl分区文件 
adb push ./main/Unlocking-SM8850.efi /data/local/tmp/
if errorlevel 1 (
    echo 推送abl分区文件 [失败] 请确保已经开启并允许调试
    pause
    goto pushabl   
)
:flefisp
echo 刷入efisp
adb shell service call  miui.mqsas.IMQSNative 21 i32 1 s16 "dd" i32 1 s16 'if=/data/local/tmp/Unlocking-SM8850.efi of=/dev/block/by-name/efisp' s16 '/data/mqsas/log.txt' i32 60
if errorlevel 1 (
    echo 刷入efisp 失败 即将重试
    pause
    goto flefisp
)
:flash
echo 正在重启到fastboot
adb reboot bootloader

if "%product%"=="byron" (
echo 等待20秒 如果报错请自己手动重启到fastboot
timeout /t 20 /nobreak >nul
) else (
echo 等待10秒 如果报错请自己手动重启到fastboot
timeout /t 10 /nobreak >nul)
:chk_fb
echo [1] 检查 Fastboot 设备...
fastboot devices | find "fastboot" >nul
if errorlevel 1 (
    echo [错误] 未检测到 Fastboot 设备，请确保手机已进入 Fastboot 模式并连接电脑。
    pause
    goto chk_fb
) else (echo [成功] 检测到 Fastboot 设备。)
echo 测试fastboot环境
fastboot getvar product

if "%product%"=="byron" (
fastboot oem unlock >nul 2>&1
echo 等待响应
timeout /t 20 /nobreak >nul
)
fastboot getvar unlocked | find "yes" >nul
if errorlevel 0 (
    echo [提示] 解锁成功 即将清除数据
) else (
    echo [警告] BL未解锁 即将重试
    timeout /t 5 /nobreak >nul
    pause
    fastboot reboot
    goto chose
)
if "%product%"=="byron" (
fastboot flash abl_a ./main/abl_a.img
fastboot flash abl_b ./main/abl_b.img
)
fastboot erase frp
fastboot erase efisp
fastboot flash misc ./main/misc_wipe.img
if "%product%"=="byron" (goto exit)
set /p fake_lock=是否需要假回锁[y/n]:
if "fake_lock"=="n" (goto exit)
fastboot flash efisp ./main/High_Version/%product%/efisp.efi
:exit
echo 解锁完成 祝您玩机顺利
fastboot reboot 
echo 此处脚本已运行完毕 如果不开机请到Recovery清除数据
pause
cmd /k