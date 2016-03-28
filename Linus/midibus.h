//
//  midibus.h
//  MidiBus
//
//  Created by Nic Grant on 23/05/2013.
//  Copyright (c) 2013 Soft Audio Pty Ltd. All rights reserved.
//
// Public C library interface

// The commentary here is brief. The documentation on the C library
// and how to use the it is currently non existent, but will be
// rectified sometime in the future
#ifndef MidiBus_midibus_h
#define MidiBus_midibus_h

#ifdef __cplusplus
extern "C" {
#endif

#include "midibus_enums.h"

// transports (no more than 8)
#define MIDIBUS_TRANSPORT_COREMIDI     0x01   // active
#define MIDIBUS_TRANSPORT_BTMIDI       0x02   // placeholder
#define MIDIBUS_TRANSPORT_AUDIOBUS     0x04   // placeholder
#define MIDIBUS_TRANSPORT_IIA          0x08   // placeholder
#define MIDIBUS_TRANSPORT_ALL          0xFF   // select all transports

// we use stdint types only, but define a similar bool
typedef uint8_t bool_t;

// MIDI message identity struct
typedef struct midibus_midi_identity
{
   eMidiBusMessageType mtype;                // type of message
   eMidiBusMessageClass mclass;              // class of message
   uint8_t mchan;                            // MIDI channel of message 1-16
   uint16_t mlen;                            // correct length for this message type
} MIDIBUS_MIDI_IDENTITY;

// maximum size of 'small' MIDI message
#define MIDIBUS_MIDI_SMALL_MSG          16

// MIDI message struct
// structure for receiving and sending MIDI events
typedef struct midibus_midi_event
{
   // index of interface that message was received on
   uint16_t index;

   // length of message in bytes
   uint16_t length;

   // message timestamp (mach absolute host time), 0 = now
   uint64_t timestamp;

   // play delay in milliseconds
   uint16_t delay_ms;

   // pointer to message data (points to 'msg_data' for small messages)
   uint8_t* data;

   // store for small messages, so don't need to alloc
   uint8_t msg_data[MIDIBUS_MIDI_SMALL_MSG];

   // for client use if desired to extend message
   void* client_data;

   // message identity (read-only set by library)
   MIDIBUS_MIDI_IDENTITY ident;

} MIDIBUS_MIDI_EVENT;

// MIDI interface struct (read only)
#define MIDIBUS_ALL_INTERFACES 255     // special wildcard interface index
typedef struct midibus_interface
{
   // index number of interface
   uint8_t index;

   // type of interface (physical, network or virtual)
   eMidiBusInterfaceType type;

   // mode of interface (source, destination or dual
   eMidiBusInterfaceMode mode;

   // transport of interface (eg. CoreMIDI)
   uint8_t transport;

   // human presentable name of interface assigned by library
   char* ident;

   // flag set if interface is enabled for incoming messages
   bool_t enabled;
    
   // number of network connections connected to this interface
   // only of relevance to network interfaces (iOS only)
   bool_t network_connections;

   // INTERFACE STATISTICS:
   // total number of events received
   uint64_t event_count;  

   // average event delivery delay (mach time)
   uint64_t transport_delay_average_mt;

   // standard deviation of above (mach time)
   uint64_t transport_delay_average_deviation_mt;

   // interface statistics - MIDI sync/clock
   bool_t clock_running;                // clock is running
   uint64_t start_tick_count;           // total number of ticks since start
   uint64_t cont_tick_count;            // ticks since continue (or start)
   float current_bpm;                   // current bpm measured
   float  min_bpm, max_bpm, avg_bpm;    // min/max/avg bpm this clock run
   float bpm_average_deviation_percent; // bpm standard deviation %
    
   // internal interface variables
   bool_t present;                           // interface present
   uint64_t tick_anchor_mt;                  // timestamp of start/cont event
   uint64_t last_tick_timestamp_received_mt; // timestamp of last tick
   bool_t is_owner;                          // set to true if app owns interface
} MIDIBUS_INTERFACE;

// structure to store musical position (bars:beats:measures)
typedef struct midibus_musical_position
{
    uint64_t bars;                            // bars
    uint8_t beats;                            // beats
    uint8_t measures;                         // measures
    uint8_t time_signature_upper;             // upper part of time signature
    uint8_t time_signature_lower;             // lower part of time signature
} MIDIBUS_MUSICAL_POSITION;

// notification types, sent to notify callback
#define MIDIBUS_NOTIFY_SETUP_CHANGED 1

// callback type when message or notification received
typedef void (*midibus_message_callback)(MIDIBUS_MIDI_EVENT* event, void* ref);
typedef void (*midibus_notify_callback)(uint8_t notify_type, void* ref);
typedef void (*midibus_sysex_notify_callback)(uint8_t index, eMidiBusStatus notify_status, void* ref);
typedef bool_t (*midibus_priority_callback)(MIDIBUS_MIDI_EVENT* event, void* ref);
    
// initialise midibus MIDI engine - *must* be called once at app init time
eMidiBusStatus midibus_initialise(const char* app_name,
                                  eMidiBusVirtualMode mode, 
                                  midibus_message_callback message_callback,
                                  void* message_callback_ref,
                                  midibus_notify_callback notify_callback,
                                  void* notify_callback_ref,
                                  midibus_sysex_notify_callback sysex_notify_callback,
                                  void* sysex_notify_callback_ref,
                                  uint8_t transports,
                                  bool_t enable_networking);

// register a priority event callback (callback returns 0 to continue, 1 to block)
bool_t midibus_register_priority_callback(midibus_priority_callback priority_callback,
                                          void* priority_callback_ref);

// interface query filter flags for use with midibus_get_interfaces
#define MIDIBUS_INTERFACE_FILTER_INC_SOURCES      0X01 // include interfaces that can receive
#define MIDIBUS_INTERFACE_FILTER_INC_DESTINATIONS 0X02 // include interfaces that can be sent to
#define MIDIBUS_INTERFACE_FILTER_INC_PHYSICAL     0X04 // include physical interfaces
#define MIDIBUS_INTERFACE_FILTER_INC_NETWORK      0X08 // include network interfaces
#define MIDIBUS_INTERFACE_FILTER_INC_VIRTUAL      0X10 // include virtual interfaces
#define MIDIBUS_INTERFACE_FILTER_ONLY_MYVIRTUAL   0X20 // only return my virtual interface

// handy preset filters returning physical OR network OR virtual ports
#define MIDIBUS_INTERFACE_FILTER_ALL_INTERFACES   0X1F // all interfaces
#define MIDIBUS_INTERFACE_FILTER_ALL_SOURCES      0X1D // all interfaces that can receive
#define MIDIBUS_INTERFACE_FILTER_ALL_DESTINATIONS 0X1E // all interfaces that can be sent to

// querying the MIDI interfaces (readonly copy returned)
// function is re-entrant so you should pass the same
// item_count & item_array pointer pointers (initialised to 0
// the first time to avoid memory leakage
// please see the documentation for this!
void midibus_get_interfaces(uint8_t* item_count,
                            MIDIBUS_INTERFACE** item_array,
                            uint8_t transport_filter,
                            uint8_t interface_filter);

// enable/disable an interface
// by default all hardware, network and your own virtual port
// are enabled - 3rd party virtual sources are disabled
void midibus_enable_interface(uint8_t interface, bool_t flag);

// channels - by default your app will listen on channel 1
#define MIDIBUS_CHANNEL_NONE    0X0000
#define MIDIBUS_CHANNEL_01      0X0001
#define MIDIBUS_CHANNEL_02      0X0002
#define MIDIBUS_CHANNEL_03      0X0004
#define MIDIBUS_CHANNEL_04      0X0008
#define MIDIBUS_CHANNEL_05      0X0010
#define MIDIBUS_CHANNEL_06      0X0020
#define MIDIBUS_CHANNEL_07      0X0040
#define MIDIBUS_CHANNEL_08      0X0080
#define MIDIBUS_CHANNEL_09      0X0100
#define MIDIBUS_CHANNEL_10      0X0200
#define MIDIBUS_CHANNEL_11      0X0400
#define MIDIBUS_CHANNEL_12      0X0800
#define MIDIBUS_CHANNEL_13      0X1000
#define MIDIBUS_CHANNEL_14      0X2000
#define MIDIBUS_CHANNEL_15      0X4000
#define MIDIBUS_CHANNEL_16      0X8000
#define MIDIBUS_CHANNEL_OMNI    0XFFFF
void midibus_set_incoming_channels(uint16_t channel_map);

// small event setup function
void midibus_setup_small_message(MIDIBUS_MIDI_EVENT* ev);

// send/flush events
eMidiBusStatus midibus_send(uint8_t interface, MIDIBUS_MIDI_EVENT* event);
eMidiBusStatus midibus_flush(uint8_t interface);

// clock control
#define MIDIBUS_CLOCK_STOP 0
#define MIDIBUS_CLOCK_START 1
#define MIDIBUS_CLOCK_CONTINUE 2
#define MIDIBUS_CLOCK_SET_BPM 3
void midibus_clock_override_latency(float seconds);
void midibus_clock_set_poll_interval(float seconds);
void midibus_clock_enable_interface(uint8_t interface, bool_t flag);
void midibus_clock(uint8_t mode, float bpm);
void midibus_clock_stamped(uint8_t mode, float bpm, uint64_t timestamp);
char* midibus_clock_get_current_time_location();
bool_t midibus_clock_running();

// get musical position (bars/beats/measures) of current interface
void midibus_get_musical_position(uint8_t interface, MIDIBUS_MUSICAL_POSITION* position);

// event routing
void midibus_route(uint8_t source_interface, uint8_t destination_interface, bool_t enabled);
bool_t midibus_route_is_connected(uint8_t source_interface, uint8_t destination_interface);

// virtual output (destination) modes
// when sending a message on your own virtual port you
// can send to your destination, source or both
#define MIDIBUS_VIRTUAL_MODE_DEST_ONLY 0
#define MIDIBUS_VIRTUAL_MODE_LOOPBACK 1
#define MIDIBUS_VIRTUAL_MODE_DUAL 3
void midibus_set_virtual_mode(uint8_t mode);

// transport functions
const char* midibus_get_transport_name(uint8_t transport);

// library trace management (not generally used in 3rd party apps)
void midibus_trace(const char* filename, bool_t console);
void midibus_suspend_trace(bool_t flag);

#ifdef __cplusplus
}
#endif

#endif
