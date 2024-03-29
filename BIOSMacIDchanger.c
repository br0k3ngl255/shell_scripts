/*
* This program is derived from code bearing the following Copyright(s)

/*                                                        -*- linux-c -*-
*   _  _ ____ __ _ ___ ____ ____ __ _ _ _ _ |
* .  \/  |--| | \|  |  |--< [__] | \| | _X_ | s e c u r e  s y s t e m s
*
* .vt|ar5k - PCI/CardBus 802.11a WirelessLAN driver for Atheros AR5k chipsets
*
* Copyright (c) 2002, .vantronix | secure systems
*                     and Reyk Floeter <reyk@va...>
*
* This program is free software ; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation ; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY ; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program ; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
* Modified by Garlaschini Davide to allow changing ids
*
*Edited by br0k3nglass for AR7 and AR9 cards
*
*
*
*/

#include <sys/mman.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define AR5K_PCICFG 0x4010 
#define AR5K_PCICFG_EEAE 0x00000001 
#define AR5K_PCICFG_CLKRUNEN 0x00000004 
#define AR5K_PCICFG_LED_PEND 0x00000020 
#define AR5K_PCICFG_LED_ACT 0x00000040 
#define AR5K_PCICFG_SL_INTEN 0x00000800 
#define AR5K_PCICFG_BCTL		 0x00001000 
#define AR5K_PCICFG_SPWR_DN 0x00010000 
 
/* EEPROM Registers in the MAC */
#define AR5211_EEPROM_ADDR 0x6000 
#define AR5211_EEPROM_DATA 0x6004
#define AR5211_EEPROM_COMD 0x6008
#define AR5211_EEPROM_COMD_READ 0x0001
#define AR5211_EEPROM_COMD_WRITE 0x0002
#define AR5211_EEPROM_COMD_RESET 0x0003
#define AR5211_EEPROM_STATUS 0x600C
#define AR5211_EEPROM_STAT_RDERR 0x0001
#define AR5211_EEPROM_STAT_RDDONE 0x0002
#define AR5211_EEPROM_STAT_WRERR 0x0003
#define AR5211_EEPROM_STAT_WRDONE 0x0004
#define AR5211_EEPROM_CONF 0x6010
 
#define VT_WLAN_IN32(a)  (*((volatile unsigned long int *)(mem + (a))))
#define VT_WLAN_OUT32(v,a) (*((volatile unsigned long int *)(mem + (a))) = (v))

#define ATHEROS_PCI_MEM_SIZE 0x10000
 
 int
 vt_ar5211_eeprom_read( unsigned char *mem,
 		       unsigned long int offset,
 		       unsigned short int *data )
 {
 	int timeout = 10000 ;
 	unsigned long int status ;
 
 	VT_WLAN_OUT32( 0, AR5211_EEPROM_CONF ),
 	usleep( 5 ) ;
 
 	/** enable eeprom read access */
 	VT_WLAN_OUT32( VT_WLAN_IN32(AR5211_EEPROM_COMD)
 		     | AR5211_EEPROM_COMD_RESET, AR5211_EEPROM_COMD) ;
 	usleep( 5 ) ;
 
 	/** set address */
 	VT_WLAN_OUT32( (unsigned char) offset, AR5211_EEPROM_ADDR) ;
 	usleep( 5 ) ;
 
 	VT_WLAN_OUT32( VT_WLAN_IN32(AR5211_EEPROM_COMD)
 		     | AR5211_EEPROM_COMD_READ, AR5211_EEPROM_COMD) ;
 
 	while (timeout > 0) {
 		usleep(1) ;
 		status = VT_WLAN_IN32(AR5211_EEPROM_STATUS) ;
 		if (status & AR5211_EEPROM_STAT_RDDONE) {
 			if (status & AR5211_EEPROM_STAT_RDERR) {
 				(void) fputs( "eeprom read access failed!\n",
 					      stderr ) ;
 				return 1 ;
 			}
 			status = VT_WLAN_IN32(AR5211_EEPROM_DATA) ;
 			*data = status & 0x0000ffff ;
 			return 0 ;
 		}
 		timeout-- ;
 	}
 
 	(void) fputs( "eeprom read timeout!\n", stderr ) ;
 
 	return 1 ;
 }
 
 int
 vt_ar5211_eeprom_write( unsigned char *mem,
 		        unsigned int offset,
 		        unsigned short int new_data )
 {
 	int timeout = 10000 ;
 	unsigned long int status ;
 	unsigned long int pcicfg ;
 	int i ;
 	unsigned short int sdata ;
 
 	/** enable eeprom access */
 	pcicfg = VT_WLAN_IN32( AR5K_PCICFG ) ;
 VT_WLAN_OUT32( ( pcicfg & ~AR5K_PCICFG_SPWR_DN ), AR5K_PCICFG ) ;
 usleep( 500 ) ;
 	VT_WLAN_OUT32( pcicfg | AR5K_PCICFG_EEAE /* | 0x2 */, AR5K_PCICFG) ;
 	usleep( 50 ) ;
 
 	VT_WLAN_OUT32( 0, AR5211_EEPROM_STATUS );
 	usleep( 50 ) ;
 
 	/* VT_WLAN_OUT32( 0x1, AR5211_EEPROM_CONF ) ; */
 	VT_WLAN_OUT32( 0x0, AR5211_EEPROM_CONF ) ;
 	usleep( 50 ) ;
 
 	i = 100 ;
 retry:
 	/** enable eeprom write access */
 	VT_WLAN_OUT32( AR5211_EEPROM_COMD_RESET, AR5211_EEPROM_COMD);
 	usleep( 500 ) ;
 
 	/* Write data */
 	VT_WLAN_OUT32( new_data, AR5211_EEPROM_DATA );
 	usleep( 5 ) ;
 
 	/** set address */
 	VT_WLAN_OUT32( offset, AR5211_EEPROM_ADDR);
 	usleep( 5 ) ;
 
 	VT_WLAN_OUT32( AR5211_EEPROM_COMD_WRITE, AR5211_EEPROM_COMD);
 	usleep( 5 ) ;
 
 	for ( timeout = 10000 ; timeout > 0 ; --timeout ) {
 		status = VT_WLAN_IN32( AR5211_EEPROM_STATUS );
 		if ( status & 0xC ) {
 			if ( status & AR5211_EEPROM_STAT_WRERR ) {
 				fprintf( stderr,
 				 "eeprom write access failed!\n");
 				return 1 ;
 			}
 			VT_WLAN_OUT32( 0, AR5211_EEPROM_STATUS );
 			usleep( 10 ) ;
 			break ;
 		}
 		usleep( 10 ) ;
 		timeout--;
 	}
 	(void) vt_ar5211_eeprom_read( mem, offset, &sdata ) ;
 	if ( ( sdata != new_data ) && i ) {
 		--i ;
 		fprintf( stderr, "Retrying eeprom write!\n");
 		goto retry ;
 	}
 
 	return !i ;
 }
 
 static void
 Usage(){
 	(void) fprintf( stderr, "Usage: idchanger {-r|-w} physical_address_base [new_VendorID new_DevID new_Subs1 new_Subs2]\nphysical_address_base is a 32 bit hex value: 0xXXXXXXXX\nids are 16 bit hex values: 0xXXXX\n") ;
 	return ;
 }
 
 int
 main( int argc, char **argv )
 {
 	unsigned long int base_addr ;
 	int fd ;
 	void *membase ;
 	unsigned short int sdata;
 	unsigned short int new_id[4];

	if ( argc <2 ) {
		Usage() ;
		return -1 ;
 	}

	if(strcmp(argv[1],"-r")==0){

		if ( argc <3 ) {
			printf( "Using read command you have to specify adapter's physical_address_base\n") ;
 			Usage() ;
 			return -1 ;
 		}

		base_addr = strtoul( argv[2], NULL, 0 ) ;
		fd = open( "/dev/mem", O_RDWR ) ;
		if ( fd < 0 ) {
			fprintf( stderr, "Open of /dev/mem failed!\n" ) ;
			return -2 ;
		}
		membase = mmap( 0, ATHEROS_PCI_MEM_SIZE, PROT_READ|PROT_WRITE,
				MAP_SHARED|MAP_FILE, fd, base_addr ) ;
		if ( membase == (void *) -1 ) {
			fprintf( stderr,
				"Mmap of device at 0x%08X for 0x%X bytes failed!\n",
				base_addr, ATHEROS_PCI_MEM_SIZE ) ;
			return -3 ;
		}
	
		printf("Accessing adapter at 0x%08X\n", base_addr);

		//Print HEX Dump
		int i;
		for(i=0x00; i<=0xFF; i++){
		printf("Reading %x ",i);
		
		if ( vt_ar5211_eeprom_read( (unsigned char *) membase, i, &sdata ) )
			fprintf( stderr, "EEPROM read failed\n" ) ;
	
		printf( "current value 0x%04X\n", sdata) ;
		
		}

	}else if(strcmp(argv[1],"-w")==0){

		if ( argc <7 ) {
			printf( "Using write command you have to specify the 4 new ids\n") ;
 			Usage() ;
 			return -1 ;
 		}

		int v;
		for(v=3; v<=6; v++){
			if ( strtoul( argv[v], NULL, 0 ) > 0xFFFF ) {
				(void) fputs(
				"Error: New ID must be 16 bit or less\n", stderr ) ;
				Usage( argv[0] ) ;
				return -2 ;
			}else{
				new_id[v-3] = (unsigned short int) strtoul( argv[v], NULL, 0 ) ;
			}
		}

		base_addr = strtoul( argv[2], NULL, 0 ) ;
		fd = open( "/dev/mem", O_RDWR ) ;
		if ( fd < 0 ) {
			fprintf( stderr, "Open of /dev/mem failed!\n" ) ;
			return -2 ;
		}
		membase = mmap( 0, ATHEROS_PCI_MEM_SIZE, PROT_READ|PROT_WRITE,
				MAP_SHARED|MAP_FILE, fd, base_addr ) ;
		if ( membase == (void *) -1 ) {
			fprintf( stderr,
				"Mmap of device at 0x%08X for 0x%X bytes failed!\n",
				base_addr, ATHEROS_PCI_MEM_SIZE ) ;
			return -3 ;
		}
	
		printf("Accessing adapter at 0x%08X\n", base_addr);
		
		#if 0
			(void) vt_ar5211_eeprom_write( (unsigned char *) membase, AR5K_EEPROM_PROTECT_OFFSET, 0 ) ;
		#endif /* #if 0 */
		
		//Modify DEVID
		
		if ( vt_ar5211_eeprom_read( (unsigned char *) membase, 0x00, &sdata ) ) fprintf( stderr, "EEPROM read failed\n" ) ;
	
		printf( "Current value 0x%04X will change to 0x%04X\n", sdata, new_id[0] ) ;
			
		if ( vt_ar5211_eeprom_write( (unsigned char *) membase, 0x00, new_id[0] ) ) fprintf( stderr, "EEPROM write failed\n" ) ;
	
		//Modify VENDOR_ID
	
		if ( vt_ar5211_eeprom_read( (unsigned char *) membase, 0x01, &sdata ) ) fprintf( stderr, "EEPROM read failed\n" ) ;
	
		printf( "Current value 0x%04X will change to 0x%04X\n", sdata, new_id[1] ) ;	
	
		if ( vt_ar5211_eeprom_write( (unsigned char *) membase, 0x01, new_id[1] ) ) fprintf( stderr, "EEPROM write failed\n" ) ;
	
		//Modify SubsystemID 0x07
	
		if ( vt_ar5211_eeprom_read( (unsigned char *) membase, 0x07, &sdata ) ) fprintf( stderr, "EEPROM read failed\n" ) ;
	
		printf( "Current value 0x%04X will change to 0x%04X\n", sdata, new_id[2] ) ;
			
		if ( vt_ar5211_eeprom_write( (unsigned char *) membase, 0x07, new_id[2] ) ) fprintf( stderr, "EEPROM write failed\n" ) ;
	
		//Modify SubsystemID 0x08
	
		if ( vt_ar5211_eeprom_read( (unsigned char *) membase, 0x08, &sdata ) ) fprintf( stderr, "EEPROM read failed\n" ) ;
	
		printf( "Current value 0x%04X will change to 0x%04X\n", sdata, new_id[3] ) ;
			
		if ( vt_ar5211_eeprom_write( (unsigned char *) membase, 0x08, new_id[3] ) ) fprintf( stderr, "EEPROM write failed\n" ) ;

	}else{
		Usage( argv[0] ) ;
 		return -1 ;
	}

 	return 0 ;
 }

