#!/usr/bin/perl
# really simple perl code for displaying the latest detection image to the framebuffer.

use Graphics::Framebuffer;
our $fb = Graphics::Framebuffer->new(SHOW_ERRORS => 0,
                                        SPLASH => 0);
$fb->clear_screen();

$fb->blit_write(
        $fb->load_image(
                {
                        'file' => './finalbirdcomp.pnm',
                        'width' => 1920,
                        'height' => 1080,
                        'scale_type' => 'min',
                        'center' => CENTER_XY
                }

        )
);

$fb->_flush_screen();
print "done!";

