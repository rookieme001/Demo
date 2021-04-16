#!/usr/bin/env python

# version : 1.11
# dslct.py : dahua software line compile toolkit
# the newest version can be found at :
# http://10.6.5.2/svnpl/BASPlatform/DSSModule/Bin/HelloModule/Trunk/Depend/dslct.py
# this file is common function for compile script, more info, see :
# http://10.6.5.2/svnpl/BASPlatform/DSSModule/Bin/HelloModule/Docs/dslct_readme.txt

import os, sys, stat, shutil, string, time
import zipfile
import tarfile
import socket, ftplib
from xml.dom import minidom

try :
	from Tkinter import *
except ImportError :
	pass

####################################################
# <1> get_target_list() : get valid target that platform support
# return : list of target

def get_target_list( platform = "all" ) :
	# valid platform : "all", "auto", "windows", "linux", "mac"
	valid_target_windows = [
			"win32-vs2005-debug",
			"win32-vs2005-release",
			"win64-vs2005-debug",
			"win64-vs2005-release",
            "android-arm-gcc46-debug",
			"android-arm-gcc46-release" ]
	valid_target_linux = [
			"linux32-centos5-gcc-debug",
			"linux32-centos5-gcc-release",
			"linux32-centos6-gcc-debug",
			"linux32-centos6-gcc-release",
			"linux64-centos6-gcc-debug",
			"linux64-centos6-gcc-release",
			"sh4-linux-uclibc-gcc-debug",
			"sh4-linux-uclibc-gcc-release",
			"android-arm-gcc46-debug",
			"android-arm-gcc46-release" ]
	valid_target_mac = [
			"mac32-llvmgcc42-debug",
			"mac32-llvmgcc42-release",
			"mac32-xcode5-debug",
			"mac32-xcode5-release",
			"mac-armv7-xcode5-debug",
			"mac-armv7-xcode5-release",
			"mac-arm64-xcode10-debug",
			"mac-arm64-xcode10-release"]

	if platform == "all" :
		return valid_target_windows + valid_target_linux + valid_target_mac
	elif platform == "auto" :
		if sys.platform == "win32" :
			return valid_target_windows
		elif sys.platform.startswith( "linux" ) :
			return valid_target_linux
		elif sys.platform == "darwin" :
			return valid_target_mac
	elif platform == "windows" :
		return valid_target_windows
	elif platform == "linux" :
		return valid_target_linux
	elif platform == "mac" :
		return valid_target_mac

	return []

####################################################
# <2> check_valid_target() : check target is valid for platform
# return True : valid; False : not valid

def check_valid_target( target, platform = "all" ) :
	if target in get_target_list( platform ) :
		return True
	return False

####################################################
# <3> do_rmtree() : remove directory tree, retry if error
# return 0 : success; 1 : failed

def inner_on_rmtree_error( func, path, exec_info ) :
	# for inner use only, if rm failed for read-only, 
	# change to read-write and try again
	if os.access( path, os.F_OK ) :
		os.chmod( path, stat.S_IREAD | stat.S_IWRITE )
		func( path )

def do_rmtree( path ) :
	for i in range(3) :
		try :
			shutil.rmtree( path, onerror = inner_on_rmtree_error )
		finally :
			if not os.access( path, os.F_OK ) :
				return 0
		time.sleep(1)

	print "delete path [%s] failed" % path
	return 1

####################################################
# <4> read_local_svn_info() : read local svn information
# return dict of svn information

def read_local_svn_info( path = ".." ) :
	# path can be local workspace path or remote svn path
	# path must be a trunk or a branch
	local_svn_info = {}
	local_svn_info["svn_path"] = "unknown"
	local_svn_info["mod_name"] = "unknown"
	local_svn_info["branch_name"] = "unknown"
	local_svn_info["checkout_ver"] = "unknown"
	local_svn_info["commit_ver"] = "unknown"
	
	oldenv = os.getenv( "LC_ALL" )
	os.putenv( "LC_ALL", "C" )
	cmd = "svn info " + path
	info = os.popen( cmd ).read()
	if oldenv != None :
		os.putenv( "LC_ALL", oldenv )

	# URL Path for
	# URL: http://10.6.5.2/svn/MobileMonitor/MobileDirectMonitor/iEasy4ip/Trunk
	# URL: http://10.6.5.2/svn/MobileMonitor/MobileDirectMonitor/iEasy4ip/Branches/P_2019.04.15_iEasy4ip_V3.71.0
	# URL: http://10.6.5.2/svn/MobileMonitor/MobileDirectMonitor/iEasy4ip/Branches/CustomBranches/C_2019.04.15_iEasy4ip_ROP0000000_LOREX_Base3.15.000_V3.3.0
	# Revision: 127854
	# Last Changed Rev: 54790
	for line in string.split( info, "\n" ) :
		if string.find( line, "URL:" ) == 0 :
			idx = line.find( "/", 12 )
			idx = line.find( "/", idx + 1 )
			local_svn_info["svn_path"] = line[idx:]
			words = string.split( line, "/" )
			print "words:", words

			local_svn_info["branch_name"] = words[-1]

			# Find mod_name
			local_svn_info["mod_name"] = words[6]

			# if words[-1] == "Trunk" :
			# 	local_svn_info["mod_name"] = words[-2]
			# elif words[-2] == "Branches":
			# 	local_svn_info["mod_name"] = words[-3]
			# else:
			# 	local_svn_info["mod_name"] = words[-4]
		elif string.find( line, "Revision:" ) == 0 :
			local_svn_info["checkout_ver"] = str(int(line[10:]))
		elif string.find( line, "Last Changed Rev:" ) == 0 :
			local_svn_info["commit_ver"] = str(int(line[18:]))

	return local_svn_info

###################get_depend_package#################################
# <5> get_depend_package() : get depend package from pkgsvr
# return 0 : success; 1 : failed

def inner_get_pkgsvr() :
	str_pkgsvr = os.getenv( "DSLCT_PKGSVR", "ftp://dslctpkgsvr.drangon.org" )
	if str_pkgsvr[0:6] != "ftp://" :
		print "bad pkgsvr [%s], use default" % str_pkgsvr
		str_pkgsvr = "ftp://dslctpkgsvr.drangon.org"

	host = str_pkgsvr[6:]
	port = 21
	user = "anonymous"
	passwd = "anonymous"
	path_prefix = "/"
	idx = host.find( "/" )
	if idx != -1 :
		path_prefix = host[idx:]
		host = host[0:idx]
	idx = host.find( "@" )
	if idx != -1 :
		user = host[0:idx]
		host = host[idx+1:]
	idx = host.find( ":" )
	if idx != -1 :
		port = int( host[idx+1:] )
		host = host[0:idx]
	idx = user.find( ":" )
	if idx != -1 :
		passwd = user[idx+1:]
		user = user[0:idx]

	# check host resolve, if bad ip, use default
	if host == "dslctpkgsvr.drangon.org" :
		try :
			ip = socket.gethostbyname( host )
		except Exception, e :
			ip = ""
		if ip[0:3] != "10." :
			host = "10.6.5.102"
			print "resolve host failed, use default ip : [%s]" % host
	
	pkgsvr = {}
	pkgsvr["host"] = host
	pkgsvr["port"] = port
	pkgsvr["user"] = user
	pkgsvr["passwd"] = passwd
	pkgsvr["path_prefix"] = path_prefix
	return pkgsvr

def get_depend_package( zipname, path, version, target_type ) :
	if not target_type in get_target_list( "all" ) :
		print "ERR : target type [ " + target_type + " ] not valid"
		return 1

	if os.access( zipname, os.F_OK ) :
		os.remove( zipname )

	pkgdir = ""
	if path[0:7] != "http://" :
		pkgdir = "./" + path + "/" + version + "/" + target_type
	else :
		idx = path.find( "/", 12 )
		idx = path.find( "/", idx + 1 )
		pkgdir = "./" + path[idx:] + "/" + version + "/" + target_type
	
	pkgsvr = inner_get_pkgsvr()

	try :
		hftp = ftplib.FTP()
		hftp.connect( pkgsvr["host"], pkgsvr["port"] )
		hftp.login( pkgsvr["user"], pkgsvr["passwd"] )
		# print "file : [%s][%s][%s]" % ( pkgsvr["path_prefix"], path, zipname )
		hftp.cwd( pkgsvr["path_prefix"] )
		hftp.cwd( pkgdir )
		fp = open( zipname, "wb" )
		hftp.retrbinary( "RETR " + zipname, fp.write )
		hftp.close()
		fp.close()
	except Exception, e :
		print "get ftp file [%s] failed, err %s" % ( zipname, e )
		return 1
	
	return 0

####################################################
# <6> generate_depend_version() : generate depend module version info to version file
# return 0 : success; 1 : failed

def inner_xml_remove_blank_node( node ) :
	nodes_to_remove = []
	for child in node.childNodes :
		if child.nodeType == minidom.Node.TEXT_NODE :
			if child.data.strip( " \t\r\n" ) == "" :
				nodes_to_remove.append( child )
		elif child.nodeType == minidom.Node.ELEMENT_NODE :
			inner_xml_remove_blank_node( child )
	for child in nodes_to_remove :
		node.removeChild( child )
	return

def inner_check_depend_version( modnode, modlist, extlist ) :
	name = modnode.getAttribute( "name" )
	ver = modnode.getAttribute( "version" )
	if name in modlist :
		if modlist[name][0] != ver and modlist[name][1] == 0 :
			print "WARN : module [%s] has diff version [ %s : %s ]" % ( name, ver, modlist[name][0] )
			modlist[name][1] = 1
	else :
		modlist[name] = [ ver, 0 ]

	nodes = modnode.getElementsByTagName( "Module" )
	for nd in nodes :
		inner_check_depend_version( nd, modlist, extlist )

	nodes = modnode.getElementsByTagName( "External" )
	for nd in nodes :
		name = nd.getAttribute( "name" )
		ver = nd.getAttribute( "version" )
		if name in extlist :
			if extlist[name][0] != ver and extlist[name][1] == 0 :
				print "WARN : external [%s] has diff version [ %s : %s ]" % ( name, ver, extlist[name][0] )
				extlist[name][1] = 1
		else :
			extlist[name] = [ ver, 0 ]

	return modlist, extlist

def generate_depend_version( target_type, verfile = "Version.xml", depfile = "DependInfo.xml" ) :
	if os.access( verfile, os.F_OK ) :
		os.remove( verfile )

	fn_d = ""
	if target_type.find( "debug" ) >= 0 :
		fn_d = "_d"

	local_svn_info = read_local_svn_info()

	# <1> generate versiom xml 
	verdom = minidom.getDOMImplementation().createDocument( None, "Versioninfo", None )
	modroot = verdom.createElement( "Module" )
	modroot.setAttribute( "name", local_svn_info["mod_name"] )
	modroot.setAttribute( "version", local_svn_info["commit_ver"] )
	modroot.setAttribute( "path", local_svn_info["svn_path"] )

	# <2> merge sub module's Version.xml file
	try :
		depdom = minidom.parse( depfile )
		if depdom.documentElement.tagName != "DependInfo" :
			print "bad depfile [%s], no DependInfo tag" % depfile
			return 1
	except Exception, e :
		print "parse depfile [%s] failed, err %s" % ( depfile, e )
		return 1

	nodes = depdom.documentElement.getElementsByTagName( "Module" )
	for nd in nodes :
		modverfile = "./" + nd.getAttribute("name") + fn_d + "/Version.xml"
		if os.access( modverfile, os.F_OK ) == False :
			print "Module Version file [%s] is not exist" % modverfile
			continue
		try :
			subdepdom = minidom.parse( modverfile )
			subnode = subdepdom.documentElement.getElementsByTagName("Module")[0]
			if nd.getAttribute("version") != subnode.getAttribute("version") :
				print "WARN : depmod [%s] has diff version [ %s : %s ]" % ( nd.getAttribute("name"), nd.getAttribute("version"), subnode.getAttribute("version") )
			inner_xml_remove_blank_node( subnode )
			modroot.appendChild( subnode )
			subdepdom = None
		except Exception, e :
			print "read sub xml failed, err : %s" % e
			return 1

	# <3> add svn:externals info
	ext = os.popen( "svn propget svn:externals ." ).read()
	# ^/DSSModule/Bin/3rdParty/Oracle@55768 Oracle
	for line in string.split( ext, "\n" ) :
		words = string.split( line )
		if len( words ) != 2 :
			if len( words ) != 0 :
				print "bad svn externals : [%s]" % line
			continue
		subwords = string.split( words[0], "@" )
		if len( subwords ) != 2 :
			print "bad svn externals : [%s]" % line
			continue
		extnode = verdom.createElement( "External" )
		extnode.setAttribute( "name", words[1] )
		extnode.setAttribute( "version", subwords[1] )
		extnode.setAttribute( "path", subwords[0] )
		modroot.appendChild( extnode )

	# <4> check version file
	modlist = {}
	extlist = {}
	inner_check_depend_version( modroot, modlist, extlist )

	# <5> write file
	fp = open( verfile, "w" )
	verdom.documentElement.appendChild( modroot )
	verdom.writexml( fp, addindent="\t", newl="\n", encoding="utf-8" )
	fp.close();
	return 0

####################################################
# <7> do_update_depend() : do update depend, get depend pkg according to depend xml
# return 0 : success; 1 : failed

def do_update_depend( target_type, depfile = "DependInfo.xml" ) :
	if not target_type in get_target_list( "all" ) :
		print "ERR : target type [ " + target_type + " ] not valid"
		return 1

	fn_d = ""
	if target_type.find( "debug" ) >= 0 :
		fn_d = "_d"

	# <1> parse DependInfo.xml
	try :
		dep = minidom.parse( depfile )
		if dep.documentElement.tagName != "DependInfo" :
			print "bad depfile [%s], no DependInfo tag" % depfile
			return 1
	except Exception, e :
		print "parse depfile [%s] failed, err %s" % ( depfile, e )
		return 1

	# <2> find need update
	# TODO : optimise, if already exit, skip it, not always get new one
	# parse local info
	# local = parse_dep_xml( "local_dep.xml" )
	# local_new = {}
	# remove item in dep who is not changed
	
	# <3> remove old module
	nodes = dep.documentElement.getElementsByTagName( "Module" )
	for nd in nodes :
		modname = nd.getAttribute( "name" )
		print "[D]", modname + fn_d
		if do_rmtree( modname + fn_d ) != 0 :
			print "rmdir " + modname + fn_d + "failed"
			return 1

	# <4> get new module
	for nd in nodes :
		modname = nd.getAttribute( "name" )
		path = nd.getAttribute( "path" )
		version = nd.getAttribute( "version" )
		print "[G]", modname + fn_d, path, version, target_type

		if target_type[0:3] == "win" :
			zipname = modname + fn_d + ".zip"
		else :
			zipname = modname + fn_d + ".tar.gz"
		
		if get_depend_package( zipname, path, version, target_type ) != 0 :
			print "get package failed"
			return 1

		try :
			if target_type[0:3] == "win" :
				zf = None
				zf = zipfile.ZipFile( zipname, "r" )
				zf.extractall()
				zf.close()
			else :
				zf = tarfile.open( zipname, "r:gz" )
				zf.extractall()
				zf.close()
				#if os.system( "tar xzf " + zipname ) != 0 :
				#	print "extract [%s] failed" % zipname
				#	return 1
				
		except Exception, e :
			print "extract [%s] failed, err %s" % ( zipname, e )
			return 1

		os.remove( zipname )

	# <5> create Version file
	ret = generate_depend_version( target_type )
	return ret 

####################################################
# <8> do_update_depend_ui() : do update depend, give ui interface if needed
# return 0 : success; 1 : failed

class gui_depend_update :
	def __init__( self, valid_target ) :
		top = Tk()
		self.top = top
		top.grid()

		lb1 = Label( top, text="TargetType" )
		lb1.grid( row=0, column=0, padx=7, pady=2 )
		self.var_target = StringVar()
		om1 = OptionMenu( top, self.var_target, *valid_target )
		self.var_target.set( valid_target[0] )
		om1.grid( row=0, column=1 )

		btn = Button( top, text="Update Depend", command=self.do_btn_update )
		btn.grid( row=1, column=0, columnspan=2 )

		self.var_info = StringVar()
		self.label_info = Label( top, textvariable=self.var_info )
		self.label_info.grid( row=2, column=0, columnspan=2, pady=5 )

	def run( self ) :
		self.top.mainloop()

	def do_btn_update( self ) :
		self.var_info.set( "updating ... please wait!" )
		self.label_info.update()

		ret = do_update_depend( self.var_target.get() )
		if ret == 0 :
			self.var_info.set( "OK -- update depend success" )
			print "OK -- update depend success"
		else :
			self.var_info.set( "ERR -- update depend failed" )
			print "ERR -- update depend failed"

def do_update_depend_ui( target_type = None ) :
	if target_type in get_target_list( "all" ) :
		return do_update_depend( target_type )

	ret = 0
	tg = ""
	valid_target = get_target_list( "auto" )
	if sys.platform == "win32" :
		# use gui ui
		gui_du = gui_depend_update( valid_target )
		gui_du.run()
	else :
		# use console ui
		for i in range( len(valid_target) ) :
			print str(i+1) + " : " + valid_target[i]
		ret = raw_input( "Target [1] : " )
		if ret == "" :
			tg = valid_target[0]
		else :
			tg = valid_target[int(ret)-1]
		ret = do_update_depend( tg )
		if ret == 0 :
			print "OK -- update depend success"
		else :
			print "ERR -- update depend failed"
	return ret

####################################################
# <9> build_depend_package() : build depend package from source
# return 0 : success; 1 : failed

def build_depend_package( modname, path, version, target_type ) :
	if not target_type in get_target_list( "all" ) :
		print "ERR : target type [ " + target_type + " ] not valid"
		return 1

	fn_d = ""
	if target_type.find( "debug" ) >= 0 :
		fn_d = "_d"
	
	# <1> checkout source
	os.chdir( "tmp_build_dir" )
	svnpath = ""
	if path[0:7] != "http://" :
		svnsvr = os.getenv( "DSLCT_SVNSVR", "http://10.6.5.2/svnpl" )
		svnpath = svnsvr + path
	else :
		svnpath = path
	# TODO : use export ?
	cmd = "svn checkout " + svnpath + "@" + version + " " + modname
	if os.system( cmd ) != 0 :
		os.chdir( "../" )
		print "run cmd failed : " + cmd
		return 1

	os.chdir( "../" )

	# <2> get depend
	try :
		dep = minidom.parse( "tmp_build_dir/" + modname + "/Depend/" + "DependInfo.xml" )
		if dep.documentElement.tagName != "DependInfo" :
			print "bad DependInfo.xml, no DependInfo tag"
			return 1
	except Exception, e :
		print "parse DependInfo.xml failed, err %s" % e
		return 1

	nodes = dep.documentElement.getElementsByTagName( "Module" )
	for nd in nodes :
		t_modname = nd.getAttribute( "name" )
		t_path = nd.getAttribute( "path" )
		t_version = nd.getAttribute( "version" )
		print "[g]", t_modname + fn_d, t_path, t_version, target_type

		if target_type[0:3] == "win" :
			t_zipname = t_modname + fn_d + ".zip"
		else :
			t_zipname = t_modname + fn_d + ".tar.gz"
	
		if os.access( "tmp_build_dir/" + t_zipname, os.F_OK ) != True :
			try :
				ret = build_package( t_modname, t_path, t_version, target_type )
			except Exception, e :
				print "build %s failed, err %s" % ( t_modname, e )
				ret = 1
			if ret != 0 :
				print "build package failed"
				return 1

		os.chdir( "tmp_build_dir/" + modname + "/Depend" )

		try :
			if target_type[0:3] == "win" :
				zf = None
				zf = zipfile.ZipFile( "../../" + t_zipname, "r" )
				zf.extractall()
				zf.close()
			else :
				# zf = tarfile.open( "../../" + t_zipname, "r:gz" )
				if os.system( "tar xzf " + "../../" + t_zipname ) != 0 :
					print "extract [%s] failed" % t_zipname
					return 1
				
		except Exception, e :
			print "extract [%s] failed, err %s" % ( t_zipname, e )
			os.chdir( "../../../" )
			return 1

		os.chdir( "../../../" )

	os.chdir( "tmp_build_dir/" + modname + "/Depend" )
	ret = generate_depend_version( target_type )
	os.chdir( "../../../" )

	# <3> build package
	print "[b]", modname + fn_d
	os.chdir( "tmp_build_dir/" + modname + "/build" )
	if target_type[0:3] == "win" :
		cmd = "build_pkg.bat " + target_type
	else :
		cmd = "bash build_pkg.sh " + target_type
	if os.system( cmd ) != 0 :
		os.chdir( "../../../" )
		print  "build pkg failed"
		return 1

	if target_type[0:3] == "win" :
		zipname = modname + fn_d + ".zip"
	else :
		zipname = modname + fn_d + ".tar.gz"
	shutil.copy( zipname, "../../" )
	os.chdir( "../../../" )

	return 0

####################################################
# <10> do_build_depend() : do build depend, build depend pkg according to depend xml
# return 0 : success; 1 : failed

def do_build_depend( target_type, depfile = "DependInfo.xml" ) :
	if not target_type in get_target_list( "all" ) :
		print "ERR : target type [ " + target_type + " ] not valid"
		return 1

	fn_d = ""
	if target_type.find( "debug" ) >= 0 :
		fn_d = "_d"

	# <1> parse DependInfo.xml
	try :
		dep = minidom.parse( depfile )
		if dep.documentElement.tagName != "DependInfo" :
			print "bad DependInfo.xml, no DependInfo tag"
			return 1
	except Exception, e :
		print "parse DependInfo.xml failed, err %s" % e
		return 1

	# <2> find need build
	# TODO : optimise, if already exit, skip it, not always get new one
	# parse local info
	# local = parse_dep_xml( "local_dep.xml" )
	# local_new = {}
	# remove item in dep who is not changed

	# <3> remove old module
	nodes = dep.documentElement.getElementsByTagName( "Module" )
	for nd in nodes :
		modname = nd.getAttribute( "name" )
		print "[D]", modname + fn_d
		if do_rmtree( modname + fn_d ) != 0 :
			print "rmdir " + modname + fn_d + "failed"
			return 1
	
	print "[D]", "tmp_build_dir"
	if do_rmtree( "tmp_build_dir" ) != 0 :
		print "rmdir tmp_build_dir failed"
		return 1

	os.mkdir( "tmp_build_dir" )

	# <4> build new module
	for nd in nodes :
		modname = nd.getAttribute( "name" )
		path = nd.getAttribute( "path" )
		version = nd.getAttribute( "version" )
		print "[B]", modname + fn_d, path, version, target_type

		if target_type[0:3] == "win" :
			zipname = modname + fn_d + ".zip"
		else :
			zipname = modname + fn_d + ".tar.gz"
	
		# NOTE : we don't support module has multiple version
		#        we only build each module once 
		#        we will generate warning message if version mismatch
		if os.access( "tmp_build_dir/" + zipname, os.F_OK ) != True :
			try :
				ret = build_depend_package( modname, path, version, target_type )
			except Exception, e :
				print "build %s failed, err %s" % ( modname, e )
				ret = 1
			if ret != 0 :
				print "build package failed"
				return 1

		try :
			if target_type[0:3] == "win" :
				zf = None
				zf = zipfile.ZipFile( "tmp_build_dir/" + zipname, "r" )
				zf.extractall()
				zf.close()
			else :
				# zf = tarfile.open( "tmp_build_dir/" + zipname, "r:gz" )
				if os.system( "tar xzf " + "tmp_build_dir/" + zipname ) != 0 :
					print "extract [%s] failed" % zipname
					return 1

		except Exception, e :
			print "extract [%s] failed, err %s" % ( zipname, e )
			return 1

	# <5> create Version file
	ret = generate_depend_version( target_type )
	return ret 

####################################################
# <11> do_build_depend_ui() : do build depend, give ui interface if needed
# return 0 : success; 1 : failed

class gui_depend_build :
	def __init__( self, valid_target ) :
		top = Tk()
		self.top = top
		top.grid()

		lb1 = Label( top, text="TargetType" )
		lb1.grid( row=0, column=0, padx=7, pady=2 )
		self.var_target = StringVar()
		om1 = OptionMenu( top, self.var_target, *valid_target )
		self.var_target.set( valid_target[0] )
		om1.grid( row=0, column=1 )

		btn = Button( top, text="Build Depend", command=self.do_btn_build )
		btn.grid( row=1, column=0, columnspan=2 )

		self.var_info = StringVar()
		self.label_info = Label( top, textvariable=self.var_info )
		self.label_info.grid( row=2, column=0, columnspan=2, pady=5 )

	def run( self ) :
		self.top.mainloop()

	def do_btn_build( self ) :
		self.var_info.set( "building ... please wait!" )
		self.label_info.update()

		ret = do_build_depend( self.var_target.get() )
		if ret == 0 :
			self.var_info.set( "OK -- build depend success" )
			print "OK -- build depend success"
		else :
			self.var_info.set( "ERR -- build depend failed" )
			print "ERR -- build depend failed"

def do_build_depend_ui( target_type = None ) :
	if target_type in get_target_list( "all" ) :
		return do_build_depend( target_type )

	ret = 0
	tg = ""
	valid_target = get_target_list( "auto" )
	if sys.platform == "win32" :
		# use gui ui
		gui_du = gui_depend_build( valid_target )
		gui_du.run()
	else :
		# use console ui
		for i in range( len(valid_target) ) :
			print str(i+1) + " : " + valid_target[i]
		ret = raw_input( "Target [1] : " )
		if ret == "" :
			tg = valid_target[0]
		else :
			tg = valid_target[int(ret)-1]
		ret = do_build_depend( tg )
		if ret == 0 :
			print "OK -- build depend success"
		else :
			print "ERR -- build depend failed"
	return ret

####################################################
# <12> gen_svninfo_header() : generate svn info header
# return 0 : success; 1 : failed

def gen_svninfo_header( fname = "svn_version.h", path = ".." ) :
	local_svn_info = read_local_svn_info( path )
	str_svn_info = """/* generate by gen_svninfo_header(), don't modify me. */
#define SVN_PATH \"%s\"
#define SVN_MOD_NAME \"%s\"
#define SVN_BRANCHE_NAME \"%s\"
#define SVN_CHECKOUT_VERSION \"%s\"
#define SVN_CHECKOUT_VERSION_NUM %s
#define SVN_LAST_COMMIT_VERSION \"%s\"
#define SVN_LAST_COMMIT_VERSION_NUM %s
#define SVN_VERSION_SUMMARY \"%s [ %s ] : %s ( co %s )\"
""" % ( local_svn_info["svn_path"], local_svn_info["mod_name"], 
		local_svn_info["branch_name"], local_svn_info["checkout_ver"],
		local_svn_info["checkout_ver"], local_svn_info["commit_ver"],
		local_svn_info["commit_ver"], local_svn_info["mod_name"],
		local_svn_info["branch_name"], local_svn_info["commit_ver"],
		local_svn_info["checkout_ver"] )

	ret = 0
	old_str = ""
	try :
		f = open( fname, "r" )
		old_str = f.read( 8000 )
		f.close()
	except Exception, e :
		# print "file open failed"
		pass
	# if the file no change, don't modify it
	if old_str == str_svn_info :
		# print "same, no change"
		return ret

	try :
		f = open( fname, "w" )
		f.write( str_svn_info )
		f.close()
	except Exception, e :
		print "file write failed"
		ret = 1

	return ret

####################################################
# <13> do_upload_package() : upload package to pkgsvr
# return 0 : success; 1 : failed

def do_upload_package( modname, path, version, target_type ) :
	if not target_type in get_target_list( "all" ) :
		print "ERR : target type [ " + target_type + " ] not valid"
		return 1

	fn_d = ""
	if target_type.find( "debug" ) >= 0 :
		fn_d = "_d"
	if target_type[0:3] == "win" :
		zipname = modname + fn_d + ".zip"
	else :
		zipname = modname + fn_d + ".tar.gz"
	
	print "zipname:", zipname
	
	pkgsvr = inner_get_pkgsvr()

	try :
		hftp = ftplib.FTP()
		hftp.connect( pkgsvr["host"], pkgsvr["port"] )
		hftp.login( pkgsvr["user"], pkgsvr["passwd"] )
		hftp.cwd( pkgsvr["path_prefix"] )
		total_path = "./" + path + "/" + version + "/" + target_type

		print "total_path", total_path

		# enter path, if not exist, create it
		for pdir in string.split( total_path, "/" ) :
			if pdir == "" or pdir == "." :
				continue
			trymkd = 0
			try :
				hftp.cwd( pdir )
			except Exception, e :
				trymkd = 1
			if trymkd == 0 :
				continue
			try :
				hftp.mkd( pdir )
				hftp.cwd( pdir )
			except Exception, e :
				print "enter dir [%s] failed, err %s" % ( pdir, e )
				return 1

		# upload file
		fp = open( zipname, "rb" )
		hftp.storbinary( "STOR " + zipname, fp )
		hftp.close()
		fp.close()
	except Exception, e :
		print "put ftp file [%s] failed, err %s" % ( zipname, e )
		return 1

	return 0

####################################################
# <14> do_upload_package_ui() : do upload package, give ui interface if needed
# return 0 : success; 1 : failed

class gui_upload_package :
	def __init__( self, valid_target ) :
		top = Tk()
		self.top = top
		top.grid()

		local_svn_info = read_local_svn_info()
		print "local_svn_info:", local_svn_info

		lb1 = Label( top, text="ModuleName" )
		lb1.grid( row=0, column=0, padx=7, pady=2 )
		self.var_modname = StringVar()
		et1 = Entry( top, textvariable=self.var_modname, width=50 )
		self.var_modname.set( local_svn_info["mod_name"] )
		et1.grid( row=0, column=1, padx=7, pady=2 )

		lb2 = Label( top, text="Path" )
		lb2.grid( row=1, column=0, padx=7, pady=2 )
		self.var_path = StringVar()
		et2 = Entry( top, textvariable=self.var_path, width=50 )
		self.var_path.set( local_svn_info["svn_path"] )
		et2.grid( row=1, column=1, padx=7, pady=2 )

		lb3 = Label( top, text="Version" )
		lb3.grid( row=2, column=0, padx=7, pady=2 )
		self.var_version = StringVar()
		et3 = Entry( top, textvariable=self.var_version, width=50 )
		self.var_version.set( local_svn_info["commit_ver"] )
		et3.grid( row=2, column=1, padx=7, pady=2 )

		lb4 = Label( top, text="TargetType" )
		lb4.grid( row=3, column=0, padx=7, pady=2 )
		self.var_target = StringVar()
		om4 = OptionMenu( top, self.var_target, *valid_target )
		self.var_target.set( valid_target[0] )
		om4.grid( row=3, column=1, padx=7, pady=2 )

		btn = Button( top, text="upload", command=self.do_btn_upload )
		btn.grid( row=4, column=0, columnspan=2 )

		self.var_info = StringVar()
		self.info = Label( top, textvariable=self.var_info )
		self.info.grid( row=5, column=0, columnspan=2, pady=5 )

	def run( self ) :
		self.top.mainloop()

	def do_btn_upload( self ) :
		self.var_info.set( "uploading ... please wait!" )
		self.info.update()

		ret = do_upload_package( self.var_modname.get(), self.var_path.get(), self.var_version.get(), self.var_target.get() );

		if ret == 0 :
			self.var_info.set( "OK -- upload success" )
		else :
			self.var_info.set( "ERR -- upload failed" )


def do_upload_package_ui( target_type = None ) :
	local_svn_info = read_local_svn_info()
	print "local_svn_info:", local_svn_info

	modname = local_svn_info["mod_name"]
	path = local_svn_info["svn_path"]
	version = local_svn_info["commit_ver"]

	print "Modename:", modname
	print "path:", path
	print "version:", version

	
	if target_type in get_target_list( "all" ) :
		return do_upload_package( modname, path, version, target_type )

	ret = 0
	valid_target = get_target_list( "auto" )
	if sys.platform == "win32" :
		# use gui ui
		gui_du = gui_upload_package( valid_target )
		gui_du.run()
	else :
		tg = ""
		# use console ui
		for i in range( len(valid_target) ) :
			print str(i+1) + " : " + valid_target[i]
		ret = raw_input( "Target [1] : " )
		if ret == "" :
			tg = valid_target[0]
		else :
			tg = valid_target[int(ret)-1]
		modname = raw_input( "ModuleName [" + modname + "] : " )
		if modname == "" :
			modname = local_svn_info["mod_name"]
		path = raw_input( "Path [" + path + "] : " )
		if path == "" :
			path = local_svn_info["svn_path"]
		version = raw_input( "SVN SRC Version [" + version + "] : " )
		if version == "" :
			version = local_svn_info["commit_ver"]
		
		ret = do_upload_package( modname, path, version, tg )
	return ret


###############################################
# main func
if __name__ == "__main__" :
	print "call func [%s] with args " % sys.argv[1], sys.argv[2:]

	if len( sys.argv ) < 2 :
		print "usage : ./dslct.py <func> <args....>"
		sys.exit( 1 )
	if not sys.argv[1] in globals() :
		print "func [%s] not found" % sys.argv[1]
		sys.exit( 1 )
	ret = globals()[ sys.argv[1] ]( *sys.argv[2:] )
	print "call func [%s] with args " % sys.argv[1], sys.argv[2:]
	print "ret : ", ret
	if type(ret) is int :
		sys.exit( ret )
	sys.exit( 0 )

