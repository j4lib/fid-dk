<?php
/**
 * WebResource tab
 * @category VuFind2
 * @package  RecordTabs
 */
namespace fid_dk_edm\RecordTab;

class WebResource extends \VuFind\RecordTab\AbstractBase
{
    /**
     * Get the on-screen description for this tab.
     *
     * @return string
     */
    public function getDescription()
    {
        return 'Links';
    }

}
