#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include "unistd.h"
#include "neon/ne_basic.h"
#include "neon/ne_auth.h"
#include "neon/ne_request.h"


char * url = "webdav.host.com";
char * user = "username";
char * pass = "password";


static int define_auth ( void *userdata, const char *realm, int attempts, char *username, char *password )
{
    strncpy ( username, user, NE_ABUFSIZ );
    strncpy ( password, pass, NE_ABUFSIZ );
    return attempts;
}



int Demo_neon ( char * path )
{
    char filepath[2048] = {0};
    ne_session * dav;
    int res, fd;

    ne_sock_init();

    dav = ne_session_create ( "http", url, 80 );

    ne_set_server_auth ( dav, define_auth, NULL );


   // ne_ssl_trust_default_ca ( dav );


	printf("\n\n###1.test mkcol!\n");
    res = ne_mkcol ( dav, "/handybuz/Matabee_360" );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
        goto _error_;
    }
    
    res = ne_mkcol ( dav, "/handybuz/Matabee_360/neontest" );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
        goto _error_;
    }


	printf("\n\n###2.test put file!\n");
    sprintf(filepath,"%s/%s", path,"test.bundle/testfile.JPG");
    
    fd = open ( filepath, O_RDONLY, S_IREAD | S_IWRITE);
	if(fd < 0){
		printf("local file is not exist!\n");
		goto _error_;
	}

    res = ne_put ( dav, "/handybuz/Matabee_360/neontest/testfile.jpg", fd );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
		printf ( "\n\nMaybe the file already exist at server!\n");
        close(fd);
        goto _error_;
    }
    close ( fd );


	printf("\n\n###3.test get file!\n");
    sprintf(filepath,"%s/%s", path,"testfile1.JPG");
	fd = open ( filepath,   O_WRONLY | O_CREAT | O_TRUNC, S_IREAD | S_IWRITE);
	if(fd < 0){
		printf("\tcould not open it!\n");
		goto _error_;
	}
    res = ne_get ( dav, "/handybuz/Matabee_360/neontest/testfile.jpg", fd );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
        close(fd);
        goto _error_;
    }
    close ( fd );

	printf("\n\n###4.test delete file!\n");
    res = ne_delete ( dav, "/handybuz/Matabee_360/neontest/testfile.jpg" );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
        goto _error_;
    }

	printf("\n\n###5.test delete folder!\n");
    res = ne_delete ( dav, "/handybuz/Matabee_360/neontest" );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
        goto _error_;
    }
    res = ne_delete ( dav, "/handybuz/Matabee_360" );
    if ( res != NE_OK )
    {
        printf ( "Request failed: %s\n", ne_get_error ( dav ) );
        goto _error_;
    }

    ne_session_destroy ( dav );

    ne_sock_exit();

	printf("\n\n###test OK!\n");

	return 0;

_error_:
	ne_session_destroy ( dav );

	ne_sock_exit();

	printf("\n\n###\ttest failed!\n");

	return 0;
}