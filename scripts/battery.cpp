/*
 * =====================================================================================
 *
 *       Filename:  battery.c
 *
 *    Description:  Description
 *
 *        Version:  1.0
 *        Created:  2024年10月10日 10时05分43秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  lijin (jin), jinli@syncore.space
 *   Organization:  SYNCORE
 *
 * =====================================================================================
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <string>
#include <iostream>

uint32_t color_map[] = {
    // 0xd70000, 0xff5f00, 0xff8700, 0xffaf00, 0xffd700,
    // 0xffff00, 0xd7ff00, 0xafff00, 0x87ff00, 0x5fff00,
    0xd70000, 0xff5f00, 0xff8700, 0xffaf00, 0xffd700,
    0xffff00, 0xd7ff00, 0xafff00, 0x87ff00, 0x98c379, 0x98c379,
    // 0x5fff00, 0x87ff00, 0xafff00, 0xd7ff00, 0xffff00,
    // 0xffd700, 0xffaf00, 0xff8700, 0xff5f00, 0xd70000,
};

const char *tmpval = "︴※ ∝ ₰ э § ö ©";
const char *charged_icon  = "❇";
// const char *charged_icon  = "※";
// const char *charging_icon = "ϟ";
// const char *charging_icon = "√";
const char *charging_icon = "∝";
const char *notCharge_icon = "§";
const char *attached_icon = "|!!|";

void read_battery_info(const char *battery_dir) {
    FILE *fp;
    char capacity_path[1024];
    char status_path[1024];
    char value[128];
    int  batVal = -1;
    char outVal[128];

    memset(outVal, 0x0, sizeof(outVal));
    // 构造电量和状态文件的路径
    sprintf(capacity_path, "/sys/class/power_supply/%s/capacity", battery_dir);
    sprintf(status_path, "/sys/class/power_supply/%s/status", battery_dir);

    // 读取电量
    fp = fopen(capacity_path, "r");
    if (fp == NULL) {
        perror("Error opening capacity file");
        return;
    }
    if (fgets(value, sizeof(value), fp) != NULL) {
        // printf("%s - Battery capacity: %s%%\n", battery_dir, value);
        batVal = atoi(value);
    }
    fclose(fp);

    // 读取状态
    fp = fopen(status_path, "r");
    if (fp == NULL) {
        perror("Error opening status file");
        return;
    }
    if (fgets(value, sizeof(value), fp) != NULL) {
        // printf("%s - Battery status: %s", battery_dir, value);
        if (strncasecmp("Discharging", value, strlen("Discharging")) == 0) {
        }
        else if (strncasecmp("Charged", value, strlen("Charged")) == 0) {
            sprintf(outVal, "#[fg=#98c379]%s", charged_icon);
        }
        else if (strncasecmp("Charging", value, strlen("Charging")) == 0) {
            sprintf(outVal, "#[fg=#d7ff00]%s", charging_icon);
        }
        else if (strncasecmp("Attached", value, strlen("Attached")) == 0) {
            sprintf(outVal, "#[fg=#d70000]%s", attached_icon);
        }
        else if (strncasecmp("Not Charging", value, strlen("Not Charging")) == 0) {
            sprintf(outVal, "#[fg=#61afef]%s", notCharge_icon);
        }
        else if (strncasecmp("Full", value, strlen("Full")) == 0) {
            sprintf(outVal, "#[fg=#98c379]%s", charged_icon);
        } else {
            sprintf(outVal, "#[fg=#d7ff00]%s", "x");
        }
    }

    if (strlen(outVal) == 0) {
        sprintf(outVal, "#");
    } else {
        sprintf(outVal, "%s#", outVal);
    }
    sprintf(outVal, "%s[fg=#%x]", outVal, color_map[batVal/10]);
    if (batVal <= 20) {
        sprintf(outVal, "%s%s", outVal, "▁");
    }
    else if (batVal <= 40) {
        sprintf(outVal, "%s%s", outVal, "▂");
    }
    else if (batVal <= 60) {
        sprintf(outVal, "%s%s", outVal, "▃");
    }
    else if (batVal <= 80) {
        sprintf(outVal, "%s%s", outVal, "▅");
    }
    else {
        sprintf(outVal, "%s%s", outVal, "▇");
    }
    sprintf(outVal, "%s%2d", outVal, batVal);

    printf("%s", outVal);
    fclose(fp);
}

int main() {
    struct dirent *de;
    DIR *dr = opendir("/sys/class/power_supply/");

    if (dr == NULL) {
        perror("Could not open current directory");
        return 0;
    }

    // 读取/sys/class/power_supply/目录下的所有文件和目录
    while ((de = readdir(dr)) != NULL) {
        // 检查设备名称是否以BAT开头
        if (strncmp(de->d_name, "BAT", 3) == 0) {
            read_battery_info(de->d_name);
            break;
        }
    }

    closedir(dr);
    return 0;
}




