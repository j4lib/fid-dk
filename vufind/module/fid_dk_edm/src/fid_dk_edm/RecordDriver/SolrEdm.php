<?php

/**
 * Model for EDM records in Solr to make them accessible within VuFind.
 *
 * PHP version 5
 * @category VuFind2
 * @package RecordDrivers
 * @author Julia Beck <j.beck@ub.uni-frankfurt.de>
 */
namespace fid_dk_edm\RecordDriver;

class SolrEdm extends \VuFind\RecordDriver\SolrDefault {

	protected $fullRecord = NULL;
	protected $classes = NULL;

	/**
	 * Create new DOMDocument from fullrecord field!
	 *
	 * @return DOMDocument;
	 */
	public function createFullRecord() {

		if (NULL === $this->fullRecord) {

      // the '\' brings you back to global namespace!
			$this->fullRecord = new \DOMDocument();
		  $success = $this->fullRecord->loadXML('<?xml version="1.0" encoding="UTF-8"?>' . $this->fields["fullrecord"]);
			if (!$success) {
				throw new \Exception("Cannot process fullRecord field!");
			}
		}
			return $this->fullRecord;
	}

	/**
	 * Call the createFullRecord() function to build the DOMDocument
	 * and split it into the different basic classes: ore:Aggregation, edm:ProvidedCHO, edm:Webresource, ...
	 *
	 * @return DOMNodelist;
	 */
	public function getFullRecordAndSplit() {

		try {
			$this->createFullRecord();
	  } catch (Exception $e) {
		  echo 'Exception abgefangen: ',  $e->getMessage(), "\n";
	  }

    if ($this->fullRecord->hasChildNodes()) {
			$childNodes = $this->fullRecord->childNodes;
			if($childNodes->item(0)->hasChildNodes() &&
			  $childNodes->item(0)->nodeName == "rdf:RDF") {

        $this->classes = $this->fullRecord->childNodes->item(0)->childNodes;
				return $this->classes;
				}
		} else {
			throw new \Exception("The record parts cannot be split into a list!");
		}

	}

	public function getClass($className) {

		$classList = [];

    foreach($this->classes as $class) {
			if($class->nodeName == $className) {
				 $classList[] = $class;
			}
		}

		return $classList;
	}

	/**
	* Get additional information of the providedCHO.
	* @return array;
	*/
	public function getMorePCHOInfos($providedCHO) {

		$pchoInfo = [];
    $pcho = $providedCHO[0];

		if(!empty($pcho) && $pcho->hasChildNodes()) {
			$pcho = $pcho->childNodes;
		}

		foreach ($pcho as $prop) {

			switch ($prop->nodeName) {
					case 'dc:description':
					  $value = $prop->nodeValue;
						if (substr($value,0,17) == 'Art/Anzahl/Umfang') {
              $pchoInfo["description"]["extent"] = $prop->nodeValue;
						} else {
					    $pchoInfo["description"][] = $prop->nodeValue;
					  }
					  break;
					case 'dc:publisher':
				  	if($prop->hasAttributes()) {
					  	$pchoInfo["publisherDetails"] = $prop->attributes->item(0)->nodeValue;
					  }	else {
					   	$pchoInfo["publisherDetails"] = $prop->nodeValue;
						}
					  break;
					case 'dc:type':
						if($prop->hasAttributes()) {
							$attr = $prop->attributes->item(0);
							if($attr->nodeName == "rdf:resource") {
								$type = $attr->nodeValue;
						  }	else {
							  $type = $prop->nodeValue;
						  }
						} else {
						  $type = $prop->nodeValue;
						}
						$pchoInfo["types"][] = $type;
				   	break;
					case 'dm2e:subtitle':
						$pchoInfo["subtitle"] = $prop->nodeValue;
						break;
					case 'dc:creator':
					  if($prop->hasAttributes()) {
						  $creator = $prop->attributes->item(0)->nodeValue;
							if ($creator == "de") {
								$creator = $prop->nodeValue;
							}
					  }	else {
							$creator = $prop->nodeValue;
						}
					  $pchoInfo["creators"][] = $creator;
						break;
					case 'dc:contributor':
					  if($prop->hasAttributes()) {
						  $contributor = $prop->attributes->item(0)->nodeValue;
					  }	else {
							$contributor = "no_GND";
						}
					  $pchoInfo["contributorsGND"][] = $contributor;
						break;
					case 'dcterms:alternative':
					  $pchoInfo["alternatives"][] = $prop->nodeValue;
						break;
					case 'dcterms:issued':
					  $pchoInfo["issued"][] = $prop->attributes->item(0)->nodeValue;
						break;
					case 'dcterms:provenance':
					  $pchoInfo["provenance"] = $prop->nodeValue;
						break;
					case 'dcterms:spatial':
						$pchoInfo["spatial"] = $prop->nodeValue;
						break;
					case 'dcterms:extent':
						$pchoInfo["extent"] = $prop->nodeValue;
						break;
					case 'dc:format':
						$pchoInfo["format"] = $prop->nodeValue;
						break;
					case 'bibo:isbn':
						$pchoInfo["isbn"] = $prop->nodeValue;
						break;
					default:
					break;

					}
		}
		return $pchoInfo;
	}

	public function getAggInfos($aggregation) {

		$aggInfo = [];
    $agg = $aggregation[0];

		if(!empty($agg) && $agg->hasChildNodes()) {
			$agg = $agg->childNodes;
		}

		foreach ($agg as $prop) {

			switch ($prop->nodeName) {
				case 'edm:dataProvider':
					if($prop->hasAttributes()) {
					  $aggInfo["dproviderID"] = $prop->attributes->item(0)->nodeValue;
					}
				break;
				case 'edm:isShownAt':
					if($prop->hasAttributes()) {
						$aggInfo["shownAt"] = $prop->attributes->item(0)->nodeValue;
					}
				break;
				default:
					# code
				break;
				}
		}

		return $aggInfo;

	}

	/**
	* Get information of a contextual class like Agents or Organizations.
	* Also suitable for core class WebResource.
	* @return array;
	*/
	public function getContextualInfos($contextualClass) {

		$infos = [];
		$infoblock = [];

		foreach ($contextualClass as $entity) {
			unset($infoblock);
			if($entity->hasAttributes()) {
				$infoblock["about"] = $entity->attributes->item(0)->nodeValue;
		  }
			if($entity->hasChildNodes()) {
				$infoblock["details"] = $entity->childNodes;
		  }
			$infos[] = $infoblock;
		}

		return $infos;

	}

	public function getMatchingDetails($entities,$id) {

		$details = NULL;

		foreach ($entities as $entity) {
		 if ($entity["about"] == $id) {
				$details = $entity["details"];
			}
		}
		return $details;

	}

	public function getLink($entityDetails) {

		$found = false;
		foreach ($entityDetails as $detail) {
			switch ($detail->nodeName) {
				case "owl:sameAs":
					if (!$found) {
						$found = true;
						return $detail->attributes->item(0)->nodeValue;
					}
					break;
				default:
					# code...
					break;
			}
		}
	}

	/**
	* Get concepts.
	* @return array;
	*/
	public function getConceptList($concepts) {

		$infos = [];

		foreach ($concepts as $concept) {
			if($concept->textContent) {
				$infos[] = $concept->textContent;
		  }
		}

		return $infos;

	}

	// ##### information directly from solr fields #####

	public function getTitle() {

		return isset($this->fields['title']) ?
					 $this->fields['title']: [];
	}

	public function getDataProvider() {

		return isset($this->fields['dataProvider']) ?
		       $this->fields['dataProvider']: [];
	}

	public function getTypes() {

		return isset($this->fields['type']) ?
		       $this->fields['type']: [];
	}

	public function getCreators() {

		return isset($this->fields['creator']) ?
		       $this->fields['creator']: [];
	}

	public function getContributors() {

		return isset($this->fields['contributor']) ?
		       $this->fields['contributor']: [];
	}

	public function getPublishers() {

		return isset($this->fields['publisher']) ?
		       $this->fields['publisher']: [];
	}

	public function getParents() {

		return isset($this->fields['isPartOf']) ?
		       $this->fields['isPartOf']: [];
	}

	public function getIssued() {

		return isset($this->fields['issued']) ?
		       $this->fields['issued']: [];
	}

  // Gets the title from solr field title to show it as breadcrumb
	public function getBreadcrumb() {
		return $this->getTitle();
	}

	//Export function
	public function getDM2ERecord() {
		return $this->fields["fullrecord"];
	}

}
