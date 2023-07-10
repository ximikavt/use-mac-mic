#include <unistd.h>
#include <CoreServices/CoreServices.h>
#include <CoreAudio/CoreAudio.h>
#include <CoreAudio/AudioHardware.h>
#include <CoreAudio/AudioHardwareBase.h>


typedef enum {
    kAudioTypeUnknown = 0,
    kAudioTypeInput   = 1,
    kAudioTypeOutput  = 2,
    kAudioTypeSystemOutput = 3,
    kAudioTypeAll = 4
} ASDeviceType;

typedef enum {
    kFormatHuman = 0,
    kFormatCLI = 1,
    kFormatJSON = 2,
} ASOutputType;

typedef enum {
    kUnmute = 0,
    kMute = 1,
    kToggleMute = 2,
} ASMuteType;

enum {
    kFunctionSetDeviceByName = 1,
    kFunctionShowHelp        = 2,
    kFunctionShowAll         = 3,
    kFunctionShowCurrent     = 4,
    kFunctionCycleNext       = 5,
    kFunctionSetDeviceByID   = 6,
    kFunctionSetDeviceByUID  = 7,
    kFunctionMute            = 8,
};



void showUsage(const char * appName);
int setMacMic(void);
bool isMacMicSet(void);
int runAudioSwitch(int argc, const char * argv[]);
const char * getDeviceUID(AudioDeviceID deviceID);
AudioDeviceID getRequestedDeviceIDFromUIDSubstring(char * requestedDeviceUID, ASDeviceType typeRequested);
AudioDeviceID getCurrentlySelectedDeviceID(ASDeviceType typeRequested);
void getDeviceName(AudioDeviceID deviceID, char * deviceName);
ASDeviceType getDeviceType(AudioDeviceID deviceID);
bool isAnInputDevice(AudioDeviceID deviceID);
bool isAnOutputDevice(AudioDeviceID deviceID);
char *deviceTypeName(ASDeviceType device_type);
void showCurrentlySelectedDeviceID(ASDeviceType typeRequested, ASOutputType outputRequested);
AudioDeviceID getRequestedDeviceID(char * requestedDeviceName, ASDeviceType typeRequested);
AudioDeviceID getNextDeviceID(AudioDeviceID currentDeviceID, ASDeviceType typeRequested);
int setDevice(AudioDeviceID newDeviceID, ASDeviceType typeRequested);
int setOneDevice(AudioDeviceID newDeviceID, ASDeviceType typeRequested);
int setAllDevicesByName(char * requestedDeviceName);
int cycleNext(ASDeviceType typeRequested);
int cycleNextForOneDevice(ASDeviceType typeRequested);
OSStatus setMute(ASDeviceType typeRequested, ASMuteType mute);
void showAllDevices(ASDeviceType typeRequested, ASOutputType outputRequested);
