<?php
namespace fid_dk_edm\Module\Configuration;

$config = array(
    'vufind' => array(
       'plugin_managers' => array(
          'recorddriver' => array(
             'factories' => array(
                'solredm'  => 'fid_dk_edm\RecordDriver\Factory::getSolrEdm',
                'solrauth' => 'fid_dk_edm\RecordDriver\Factory::getSolrAuth',
             ),
           ),
          'recordtab' => array(
            'invokables' => array (
                    'webresource' => 'fid_dk_edm\RecordTab\WebResource',
                    'staffviewarray' => 'fid_dk_edm\RecordTab\StaffViewArray',
             ),
           ),
        ),
       'recorddriver_tabs' => array(
           'fid_dk_edm\RecordDriver\SolrEdm' => array(
              'tabs' => array(
                  'Holdings' => 'HoldingILS', 'Description' => 'Description',
                  'WebResource' => 'WebResource','Details' => 'StaffViewArray',
                  'TOC' => 'TOC', 'UserComments' => 'UserComments',
                  'Reviews' => 'Reviews', 'Excerpt' => 'Excerpt',
                  'HierarchyTree' => 'HierarchyTree', 'Map' => 'Map',
               ),
              'defaultTab' => null,
            ),
          'fid_dk_edm\RecordDriver\SolrAuth' => array(
              'tabs' => array(
                  'Details' => 'StaffViewArray',
              ),
              'defaultTab' => null,
            ),
        ),
        'search_backend' => array(
            'factories' => array(
                'SolrAuth' => 'fid_dk_edm\Search\Factory\SolrAuthBackendFactory',
            ),
        ),
    ),
    'controllers' => array(
       'invokables' => array(
         'authority' => 'fid_dk_edm\Controller\AuthorityController',
         //'solrauthrecord' => 'fid_dk_edm\Controller\SolrauthrecordController',
         'spages'  => 'fid_dk_edm\Controller\SpagesController',

      ),
    ),
    /*
    'service_manager' => array(
      'invokables' => array(
        'fid_dk_edm\Search' => 'VuFindSearch\Service',

     ),
   ),*/
);

$staticRoutes = array(
    'spages/uber',
    'spages/beirat',
    'spages/netzwerk',
    'spages/dokumentation',
    'spages/netzwerke',
    'spages/contact',
    'spages/suchen',
    'spages/news',
    'spages/themen',
    'spages/contents',
    'spages/neuerwerb',
    'spages/fernleihe',
    'spages/kaufvorschlag',
    'spages/impressum',
    'spages/copyright',
    'spages/verweise',
    'spages/datenschutz',
    'spages/haftung',
);

return $config;
