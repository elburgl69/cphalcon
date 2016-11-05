
/*
 +------------------------------------------------------------------------+
 | Phalcon Framework                                                      |
 +------------------------------------------------------------------------+
 | Copyright (c) 2011-2016 Phalcon Team (https://phalconphp.com)       |
 +------------------------------------------------------------------------+
 | This source file is subject to the New BSD License that is bundled     |
 | with this package in the file docs/LICENSE.txt.                        |
 |                                                                        |
 | If you did not receive a copy of the license and are unable to         |
 | obtain it through the world-wide-web, please send an email             |
 | to license@phalconphp.com so we can send you a copy immediately.       |
 +------------------------------------------------------------------------+
 | Authors: Andres Gutierrez <andres@phalconphp.com>                      |
 |          Eduar Carvajal <eduar@phalconphp.com>                         |
 +------------------------------------------------------------------------+
 */

namespace Phalcon\Assets;

use Phalcon\Tag;
use Phalcon\Assets\Resource;
use Phalcon\Assets\Collection;
use Phalcon\Assets\Exception;
use Phalcon\Assets\Resource\Js as ResourceJs;
use Phalcon\Assets\Resource\Css as ResourceCss;
use Phalcon\Assets\Inline\Css as InlineCss;
use Phalcon\Assets\Inline\Js as InlineJs;

/**
 * Phalcon\Assets\Manager
 *
 * Manages collections of CSS/Javascript assets
 */
class Manager
{

	/**
	 * Options configure
	 * @var array
	 */
	protected _options;

	protected _collections;

	protected _implicitOutput = true;

	/**
	 * Phalcon\Assets\Manager
	 *
	 * @param array options
	 */
	public function __construct(options = null)
	{
		if typeof options == "array" {
			let this->_options = options;
		}
	}

	/**
	 * Sets the manager options
	 */
	public function setOptions(array! options) -> <Manager>
	{
		let this->_options = options;
		return this;
	}

	/**
	 * Returns the manager options
	 */
	public function getOptions() -> array
	{
		return this->_options;
	}

	/**
	 * Sets if the HTML generated must be directly printed or returned
	 */
	public function useImplicitOutput(boolean implicitOutput) -> <Manager>
	{
		let this->_implicitOutput = implicitOutput;
		return this;
	}


	/**
	* Adds a Css resource to the 'css' collection
	*
	*<code>
	*	$assets->addCss("css/bootstrap.css");
	*	$assets->addCss("http://bootstrap.my-cdn.com/style.css", false);
	*</code>
	*/
	public function addCss(string! path, local = true, filter = true, var attributes = null) -> <Manager>
	{
		this->addResourceByType("css", new ResourceCss(path, local, filter, attributes));
		return this;
	}

	/**
	 * Adds an inline Css to the 'css' collection
	 */
	public function addInlineCss(string content, filter = true, var attributes = null) -> <Manager>
	{
		this->addInlineCodeByType("css", new InlineCss(content, filter, attributes));
		return this;
	}

	/**
	 * Adds a javascript resource to the 'js' collection
	 *
	 *<code>
	 * $assets->addJs("scripts/jquery.js");
	 * $assets->addJs("http://jquery.my-cdn.com/jquery.js", false);
	 *</code>
	 */
	public function addJs(string! path, local = true, filter = true, attributes = null) -> <Manager>
	{
		this->addResourceByType("js", new ResourceJs(path, local, filter, attributes));
		return this;
	}

	/**
	 * Adds an inline javascript to the 'js' collection
	 */
	public function addInlineJs(string content, filter = true, attributes = null) -> <Manager>
	{
		this->addInlineCodeByType("js", new InlineJs(content, filter, attributes));
		return this;
	}

	/**
	 * Adds a resource by its type
	 *
	 *<code>
	 * $assets->addResourceByType("css",
	 *     new \Phalcon\Assets\Resource\Css("css/style.css")
	 * );
	 *</code>
	 */
	public function addResourceByType(string! type, <$Resource> $resource) -> <Manager>
	{
		var collection;

		if !fetch collection, this->_collections[type] {
			let collection = new Collection();
			let this->_collections[type] = collection;
		}

		/**
		 * Add the resource to the collection
		 */
		collection->add($resource);

		return this;
	}

	/**
	 * Adds an inline code by its type
	 */
	public function addInlineCodeByType(string! type, <$Inline> code) -> <Manager>
	{
		var collection;

		if !fetch collection, this->_collections[type] {
			let collection = new Collection();
			let this->_collections[type] = collection;
		}

		/**
		 * Add the inline code to the collection
		 */
		collection->addInline(code);

		return this;
	}

	/**
	 * Adds a raw resource to the manager
	 *
	 *<code>
	 * $assets->addResource(
	 *     new Phalcon\Assets\Resource("css", "css/style.css")
	 * );
	 *</code>
	 */
	public function addResource(<$Resource> $resource) -> <Manager>
	{
		/**
		 * Adds the resource by its type
		 */
		this->addResourceByType($resource->getType(), $resource);
		return this;
	}

	/**
	 * Adds a raw inline code to the manager
	 */
	public function addInlineCode(<$Inline> code) -> <Manager>
	{
		/**
		 * Adds the inline code by its type
		 */
		this->addInlineCodeByType(code->getType(), code);
		return this;
	}

	/**
	 * Sets a collection in the Assets Manager
	 *
	 *<code>
	 * $assets->set("js", $collection);
	 *</code>
	 */
	public function set(string! id, <Collection> collection) -> <Manager>
	{
		let this->_collections[id] = collection;
		return this;
	}

	/**
	* Returns a collection by its id
	*
	*<code>
	* $scripts = $assets->get("js");
	*</code>
	*/
	public function get(string! id) -> <Collection>
	{
		var collection;

		if !fetch collection, this->_collections[id] {
			throw new Exception("The collection does not exist in the manager");
		}

		return collection;
	}

	/**
	 * Returns the CSS collection of assets
	 */
	public function getCss() -> <Collection>
	{
		var collection;

		/**
		 * Check if the collection does not exist and create an implicit collection
		 */
		if !fetch collection, this->_collections["css"] {
			return new Collection();
		}

		return collection;
	}

	/**
	 * Returns the CSS collection of assets
	 */
	public function getJs() -> <Collection>
	{
		var collection;

		/**
		 * Check if the collection does not exist and create an implicit collection
		 */
		if !fetch collection, this->_collections["js"] {
			return new Collection();
		}

		return collection;
	}

	/**
	 * Creates/Returns a collection of resources
	 */
	public function collection(string name) -> <Collection>
	{
		var collection;

		if !fetch collection, this->_collections[name] {
			let collection = new Collection();
			let this->_collections[name] = collection;
		}

		return collection;
	}

	/**
	 * Traverses a collection calling the callback to generate its HTML
	 *
	 * @param \Phalcon\Assets\Collection collection
	 * @param callback callback
	 * @param string type
	 */
	public function output(<Collection> collection, callback, type) -> string | null
	{
		var output, resources, filters, prefix, sourceBasePath = null,
			targetBasePath = null, options, collectionSourcePath, completeSourcePath,
			collectionTargetPath, completeTargetPath, filteredJoinedContent, join,
			aResource, filterNeeded, local, sourcePath, targetPath, path, prefixedPath,
			attributes, parameters, html, useImplicitOutput, content, mustFilter,
			filter, filteredContent, typeCss, targetUri;

		let useImplicitOutput = this->_implicitOutput;

		let output = "";

        /**
         * First collect basic data to proces.
         */


		/**
		 * Get the resources as an array
		 */
		let resources = collection->getResources();

		/**
		 * Get filters in the collection
		 */
		let filters = collection->getFilters();

		/**
		 * Get the collection's prefix
		 */
		let prefix = collection->getPrefix();

		let typeCss = "css";

		/**
		 * Prepare options if the collection must be filtered
		 */
		if count(filters) {

		/**
		 * Prepare options if the collection must be filtered and / or joined
		 *
		 * The objective is to obtain the source and target paths. In particular:
		 *  - CompleteSourcePath as: options["sourceBasePath"] . collection->getSourcePath()
		 *  - CompleteTargetPath as: options["targetBasePath"] . collection->getTargetPath()
		 *
		 * In case of join = true, a check is made if CompleteTargetPath has content and if it is not a directory. In both
		 * cases an error is thrown.
		 */
		if count(filters) || join {

			let options = this->_options;

			/**
			 * Check for global options in the assets manager
			 */
			if typeof options == "array" {

				/**
				 * The source base path is a global location where all resources are located
				 */
				fetch sourceBasePath, options["sourceBasePath"];

				/**
				 * The target base path is a global location where all resources are written
				 */
				fetch targetBasePath, options["targetBasePath"];
			}

			/**
			 * Check if the collection have its own source base path
			 */
			let collectionSourcePath = collection->getSourcePath();

			/**
			 * Concatenate the global base source path with the collection one
			 */
			if collectionSourcePath {
				let completeSourcePath = sourceBasePath . collectionSourcePath;
			} else {
				let completeSourcePath = sourceBasePath;
			}

			/**
			 * Check if the collection have its own target base path
			 */
			let collectionTargetPath = collection->getTargetPath();

			/**
			 * Concatenate the global base source path with the collection one
			 */
			if collectionTargetPath {
				let completeTargetPath = targetBasePath . collectionTargetPath;
			} else {
				let completeTargetPath = targetBasePath;
			}

			/**
			 * Global filtered content
			 */
			let filteredJoinedContent = "";

			/**
			 * Check if the collection have its own target base path
			 */
			let join = collection->getJoin();

			/**
			 * Check for valid target paths if the collection must be joined
			 */
			if join {
				/**
				* We need a valid final target path
				*/
				if !completeTargetPath {
					throw new Exception("Path '". completeTargetPath. "' is not a valid target path (1)");
				}

				if is_dir(completeTargetPath) {
					throw new Exception("Path '". completeTargetPath. "' is not a valid target path (2), is dir.");
				}
			}
		}

		/**
		 * walk in resources
		 *
		 * All resources of the collection are processed. For every type of collection!
		 *
		 * First default on not filtering!
		 *  let filterNeeded = false
		 *  let type = resource->getType(), so its type (css or js for now).
		 *  let local = resource->getLocal(). is this resource a local resource?
		 */
		for aResource in resources {

			let filterNeeded = false;
			let type = aResource->getType();

			/**
			 * Is the resource local?
			 */
			let local = aResource->getLocal();

			/**
			 * If the collection must not be joined we must print a HTML for each one, so process to be filtered an joined
			 * stuff in this section and all other stuff in the else clause. Note:
			 * in this if:
			 *  - completeSourcePath = options["sourceBasePath"] . collection->getSourcePath(); Manager / Collection for all
			 *      Resources. This can be empty!
             *  - completeTargetPath as: options["targetBasePath"] . collection->getTargetPath(); Manager / Collection for all
             *      Resources. This one actually points to a local location on the filesystem, and is not a dir.
             * In the else part completeSourcePath and completeSourcePath are uninitialized!
			 */
			if count(filters) || join {
			    /**
			     * If the resource is local:
			     *      Let sourcePath =  resource->getRealSourcePath(completeSourcePath);
			     *      if sourcePath is empty, throw an error.
			     * else
			     *     let sourcePath = resource->getPath();
			     *      let filterNeeded = true;
			     * Note:
			     *  - resource->getRealSourcePath(completeSourcePath); treats completeSourcePath as a directory.
			     *  - filterNeeded is set to true for not local resources. However no filters can be set if we only join!
			     *      Filtering anyhow for not local resources is not described in the documentation!?
			     */
				if local {

					/**
					 * Get the complete path
					 */
					let sourcePath = aResource->getRealSourcePath(completeSourcePath);

					/**
					 * We need a valid source path
					 */
					if !sourcePath {
						let sourcePath = aResource->getPath();
						throw new Exception("Resource '". sourcePath. "' does not have a valid source path");
					}
				} else {

					/**
					 * Get the complete source path
					 */
					let sourcePath = aResource->getPath();

					/**
					 * resources paths are always filtered
					 */
					let filterNeeded = true;
				}

				/**
				 * Get the target path, we need to write the filtered content to a file
				 * When joining, completeTargetPath point to (what will be) a file, otherwise it is null or a path to a
				 * directory. So set targetPath to completePath for to be joined resources otherwise get targetPath from
				 * the resource.
				 *				 *
				 * Then check the following:
				 * - If targetPath is empty at this stage, throw an error.
				 * - If the resource is a local resource the source and target must not be the same.
				 * - Finally if Local and targetPath references an existing file, the date modified of the both files
				 * - is compared. If the targetPath modification timestamp is smaller than the that of the sourcePath,
				 *   filtering is required. Also when targetPath does not exist.
				 *
				 * Note: the last check does not concern Joined files since we are looking at filtered replica's of a
				 * original file. These do not exist when joining, so when joining, filtering is always performed!
				 *
				 * The major result here is that filterNeeded might be set to true, which influences further processing.
				 */
				if join == true {
                    let targetPath = completeTargetPath;
				} else {
				    let targetPath = aResource->getRealTargetPath(completeTargetPath);
                }

				/**
				 * We need a valid final target path
				 */
				if !targetPath {
					throw new Exception("Resource '". sourcePath. "' does not have a valid target path");
				}

				if local {

					/**
					 * Make sure the target path is not the same source path
					 */
					if targetPath == sourcePath {
						throw new Exception("Resource '". targetPath. "' have the same source and target paths");
					}

					if file_exists(targetPath) {
						if compare_mtime(targetPath, sourcePath) {
							let filterNeeded = true;
						}
					} else {
						let filterNeeded = true;
					}
				}
			} else {
			    /**
			     * No filters or joining should be applied, so the HTML pointing to the original location of the resource
			     * should be outputed or returned.
			     *
			     * First:
			     *  let path = resource->getRealTargetUri(); This get's the real file location of the required Target
			     *  Path that should be set for the resource! In cases where we want to output to point to the orginal,
			     *  this value is that of what is used with AddJS() / AddCss() etc methods.
			     *
			     * When prefix is set, this value is prefixed to the retrieved pathe, to get to the final destination.
			     * Get extra attributes that might have been set with AddJS() / AddCss() etc methods.
			     *
			     * Then call a callback, that was given as a callback to this function. Which is normally a call to
			     * Tag::styleSheetLink() or Tag::javascriptInclude()
			     *
			     * Depending on useImplicit output, write the result to the output buffer or return a string and the stop
			     * processing this resource.
			     */

				/**
				 * If there are not filters, just print/buffer the HTML
				 */
				let path = aResource->getRealTargetUri();

				if prefix {
					let prefixedPath = prefix . path;
				} else {
					let prefixedPath = path;
				}

				/**
				 * Gets extra HTML attributes in the resource
				 */
				let attributes = aResource->getAttributes();

				/**
				 * Prepare the parameters for the callback
				 */
				let parameters = [];
				if typeof attributes == "array" {
					let attributes[0] = prefixedPath;
					let parameters[] = attributes;
				} else {
					let parameters[] = prefixedPath;
				}
				let parameters[] = local;

				/**
				 * Call the callback to generate the HTML
				 */
				let html = call_user_func_array(callback, parameters);

				/**
				 * Implicit output prints the content directly
				 */
				if useImplicitOutput == true {
					echo html;
				} else {
					let output .= html;
				}

				continue;
			}

            /**
             * filterNeeded started as false for each loop over the resources. It can only be set to true at the point when:
             * a filter and / or joining should be applied. When true, then:
             *  let content = resource->getContent(completeSourcePath); Get te content of the file in a string.
             *  let mustFilter = resource->getFilter() && count(filters);
             *
             * If mustFilter is true, loop all the filters an aply their filter method on the content.
             * Store the result in either filteredJoinedContent (concatenate) when joining or filteredContent.
             *
             * When join is not required, write filteredContent to targetFile.
             *
             * So at this filters are applied and te result is written to a targetPath if joining is not required, for
             * all resources in te collection. When joining is required, the filtered content (if filtering is applied,
             * otherwise te unfiltered content) is concatednated and stored in a string filteredJoinedContent.
             */
			if filterNeeded == true {

				/**
				 * Gets the resource's content
				 */
				let content = aResource->getContent(completeSourcePath);

				/**
				 * Check if the resource must be filtered. This is true when:
				 * The filter property on the resource is set and when there are filters set in the collection!
				 */
				let mustFilter = aResource->getFilter() && count(filters);

				/**
				 * Only filter the resource if it's marked as 'filterable', set through addCSS() and addJs() etc.
				 */
				if mustFilter == true {
                    /**
                     * Loop the filters array and chech if the content is an object.
                     * And call for each object it's filter method on the content.
                     */
					for filter in filters {

						/**
						 * Filters must be valid objects
						 */
						if typeof filter != "object" {
							throw new Exception("Filter is invalid");
						}

						/**
						 * Calls the method 'filter' which must return a filtered version of the content
						 */
						let filteredContent = filter->filter(content),
							content = filteredContent;
					}
					/**
					 * Update the joined filtered content, when joining is required.
					 */
					if join == true {
						if type == typeCss {
							let filteredJoinedContent .= filteredContent;
						} else {
							let filteredJoinedContent .= filteredContent . ";";
						}
					}
				} else {

					/**
					 * Update the joined or the filtered content.
					 * when Join is required, update filteredJoinedContent with the content of this resource, else
					 * set filteredContent to the content of this resource.
					 */
					if join == true {
						let filteredJoinedContent .= content;
					} else {
						let filteredContent = content;
					}
				}

				if !join {
					/**
					 * When not joining, write the content of this resource to targetPath. ie create a copy of the original
					 * file at the target location.
					 *
					 * Write the file using file-put-contents. This respects the openbase-dir also
					 * writes to streams
					 */
					file_put_contents(targetPath, filteredContent);
				}
			}

            /**
             * When join is not set on the collection, prepare the output.
			 * So call a callback, that was given as a callback to this function. Which is normally a call to
			 * Tag::styleSheetLink() or Tag::javascriptInclude()
             */
			if !join {

				/**
				 * Generate the HTML using the original path in the resource
				 */
				let path = aResource->getRealTargetUri();

				if prefix {
					let prefixedPath = prefix . path;
				} else {
					let prefixedPath = path;
				}

				/**
				 * Gets extra HTML attributes in the resource
				 */
				let attributes = aResource->getAttributes();

				/**
				 * Filtered resources are always local
				 */
				let local = true;

				/**
				 * Prepare the parameters for the callback
				 */
				let parameters = [];
				if typeof attributes == "array" {
					let attributes[0] = prefixedPath;
					let parameters[] = attributes;
				} else {
					let parameters[] = prefixedPath;
				}
				let parameters[] = local;

				/**
				* Call the callback to generate the HTML
				*/
				let html = call_user_func_array(callback, parameters);

				/**
				* Implicit output prints the content directly
				*/
				if useImplicitOutput == true {
					echo html;
				} else {
					let output .= html;
				}
			}
		}

		if join {

			/**
			 * Write the file using file_put_contents. This respects the openbase-dir also
			 * writes to streams
			 */
			file_put_contents(completeTargetPath, filteredJoinedContent);

			/**
			 * Generate the HTML using the original path in the resource
			 */
			let targetUri = collection->getTargetUri();

			if prefix {
				let prefixedPath = prefix . targetUri;
			} else {
				let prefixedPath = targetUri;
			}

			/**
			 * Gets extra HTML attributes in the collection
			 */
			let attributes = collection->getAttributes();

			/**
			 *  Gets local
			 */
			let local = collection->getTargetLocal();

			/**
			 * Prepare the parameters for the callback
			 */
			let parameters = [];
			if typeof attributes == "array" {
				let attributes[0] = prefixedPath;
				let parameters[] = attributes;
			} else {
				let parameters[] = prefixedPath;
			}
			let parameters[] = local;

			/**
			 * Call the callback to generate the HTML
			 */
			let html = call_user_func_array(callback, parameters);

			/**
			 * Implicit output prints the content directly
			 */
			if useImplicitOutput == true {
				echo html;
			} else {
				let output .= html;
			}
		}

		return output;
	}

	/**
	 * Traverses a collection and generate its HTML
	 *
	 * @param \Phalcon\Assets\Collection collection
	 * @param string type
	 */
	public function outputInline(<Collection> collection, type) -> string
	{
		var output, html, codes, filters, filter, code, attributes, content, join, joinedContent;

		let output = "",
			html = "",
			joinedContent = "";

		let codes = collection->getCodes(),
			filters = collection->getFilters(),
			join = collection->getJoin() ;

		if count(codes) {
			for code in codes {
				let attributes = code->getAttributes(),
					content = code->getContent();

				for filter in filters {
					/**
					 * Filters must be valid objects
					 */
					if typeof filter != "object" {
						throw new Exception("Filter is invalid");
					}

					/**
					 * Calls the method 'filter' which must return a filtered version of the content
					 */
					let content = filter->filter(content);
				}

				if join {
					let joinedContent .= content;
				} else {
					let html .= Tag::tagHtml(type, attributes, false, true) . content . Tag::tagHtmlClose(type, true);
				}
			}

			if join {
				let html .= Tag::tagHtml(type, attributes, false, true) . joinedContent . Tag::tagHtmlClose(type, true);
			}

			/**
			 * Implicit output prints the content directly
			 */
			if this->_implicitOutput == true {
				echo html;
			} else {
				let output .= html;
			}
		}

		return output;
	}

	/**
	 * Prints the HTML for CSS resources
	 *
	 * @param string collectionName
	 */
	public function outputCss(collectionName = null) -> string
	{
		var collection;

		if !collectionName {
			let collection = this->getCss();
		} else {
			let collection = this->get(collectionName);
		}

		return this->output(collection, ["Phalcon\\Tag", "stylesheetLink"], "css");
	}

	/**
	 * Prints the HTML for inline CSS
	 *
	 * @param string collectionName
	 */
	public function outputInlineCss(collectionName = null) -> string
	{
		var collection;

		if !collectionName {
			let collection = this->getCss();
		} else {
			let collection = this->get(collectionName);
		}

		return this->outputInline(collection, "style");
	}

	/**
	 * Prints the HTML for JS resources
	 *
	 * @param string collectionName
	 */
	public function outputJs(collectionName = null) -> string
	{
		var collection;

		if !collectionName {
			let collection = this->getJs();
		} else {
			let collection = this->get(collectionName);
		}

		return this->output(collection, ["Phalcon\\Tag", "javascriptInclude"], "js");
	}

	/**
	 * Prints the HTML for inline JS
	 *
	 * @param string collectionName
	 */
	public function outputInlineJs(collectionName = null) -> string
	{
		var collection;

		if !collectionName {
			let collection = this->getJs();
		} else {
			let collection = this->get(collectionName);
		}

		return this->outputInline(collection, "script");
	}

	/**
	 * Returns existing collections in the manager
	 */
	public function getCollections() -> <Collection[]>
	{
		return this->_collections;
	}

	/**
	 * Returns true or false if collection exists
	 */
	public function exists(string! id) -> bool
	{
		return isset this->_collections[id];
	}
}
