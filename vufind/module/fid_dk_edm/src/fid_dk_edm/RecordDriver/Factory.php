<?php
/**
 * Userdefined Record Driver Factory Class
 *
 * PHP version 5
 *
 * Record Driver Factory for SolrEdm based on the model of the Factory Class
 * written by Demian Katz.
 *
 * @category VuFind2
 * @package  RecordDrivers
 * @author   Julia Beck <j.beck@ub.uni-frankfurt.de>
 */
namespace fid_dk_edm\RecordDriver;
use Zend\ServiceManager\ServiceManager;

class Factory
{
    /**
     * Factory for SolrEdm record driver.
     *
     * @param ServiceManager $sm Service manager.
     *
     * @return SolrEdm
     */
    public static function getSolrEdm(ServiceManager $sm)
    {
        return new SolrEdm(
            $sm->getServiceLocator()->get('VuFind\RecordDriverPluginManager')
            );
    }

    /**
     * Factory for the authority record driver.
     *
     * @param ServiceManager $sm Service manager.
     *
     * @return SolrAuth
     */
    public static function getSolrAuth(ServiceManager $sm)
    {
        return new SolrAuth(
            $sm->getServiceLocator()->get('VuFind\Config')->get('config'),
            null,
            $sm->getServiceLocator()->get('VuFind\Config')->get('searches')
        );
    }

}
