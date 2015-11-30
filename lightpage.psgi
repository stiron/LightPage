use strict;
use warnings;

use LightPage;

my $app = LightPage->apply_default_middlewares(LightPage->psgi_app);
$app;

