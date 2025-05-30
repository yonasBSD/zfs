dnl #
dnl # Supported mkdir() interfaces checked newest to oldest.
dnl #
AC_DEFUN([ZFS_AC_KERNEL_SRC_MKDIR], [
	dnl #
	dnl # 6.15 API change
	dnl # mkdir() returns struct dentry *
	dnl #
	ZFS_LINUX_TEST_SRC([mkdir_return_dentry], [
		#include <linux/fs.h>

		static struct dentry *mkdir(struct mnt_idmap *idmap,
			struct inode *inode, struct dentry *dentry,
			umode_t umode) { return dentry; }
		static const struct inode_operations
		    iops __attribute__ ((unused)) = {
			.mkdir = mkdir,
		};
	],[])

	dnl #
	dnl # 6.3 API change
	dnl # mkdir() takes struct mnt_idmap * as the first arg
	dnl #
	ZFS_LINUX_TEST_SRC([mkdir_mnt_idmap], [
		#include <linux/fs.h>

		static int mkdir(struct mnt_idmap *idmap,
			struct inode *inode, struct dentry *dentry,
			umode_t umode) { return 0; }
		static const struct inode_operations
		    iops __attribute__ ((unused)) = {
			.mkdir = mkdir,
		};
	],[])

	dnl #
	dnl # 5.12 API change
	dnl # The struct user_namespace arg was added as the first argument to
	dnl # mkdir()
	dnl #
	ZFS_LINUX_TEST_SRC([mkdir_user_namespace], [
		#include <linux/fs.h>

		static int mkdir(struct user_namespace *userns,
			struct inode *inode, struct dentry *dentry,
		    umode_t umode) { return 0; }

		static const struct inode_operations
		    iops __attribute__ ((unused)) = {
			.mkdir = mkdir,
		};
	],[])

	dnl #
	dnl # 3.3 API change
	dnl # The VFS .create, .mkdir and .mknod callbacks were updated to take a
	dnl # umode_t type rather than an int.  The expectation is that any backport
	dnl # would also change all three prototypes.  However, if it turns out that
	dnl # some distribution doesn't backport the whole thing this could be
	dnl # broken apart into three separate checks.
	dnl #
	ZFS_LINUX_TEST_SRC([inode_operations_mkdir], [
		#include <linux/fs.h>

		static int mkdir(struct inode *inode, struct dentry *dentry,
		    umode_t umode) { return 0; }

		static const struct inode_operations
		    iops __attribute__ ((unused)) = {
			.mkdir = mkdir,
		};
	],[])
])

AC_DEFUN([ZFS_AC_KERNEL_MKDIR], [
	dnl #
	dnl # 6.15 API change
	dnl # mkdir() returns struct dentry *
	dnl #
	AC_MSG_CHECKING([whether iops->mkdir() returns struct dentry*])
	ZFS_LINUX_TEST_RESULT([mkdir_return_dentry], [
		AC_MSG_RESULT(yes)
		AC_DEFINE(HAVE_IOPS_MKDIR_DENTRY, 1,
		    [iops->mkdir() returns struct dentry*])
	],[
		dnl #
		dnl # 6.3 API change
		dnl # mkdir() takes struct mnt_idmap * as the first arg
		dnl #
		AC_MSG_CHECKING([whether iops->mkdir() takes struct mnt_idmap*])
		ZFS_LINUX_TEST_RESULT([mkdir_mnt_idmap], [
			AC_MSG_RESULT(yes)
			AC_DEFINE(HAVE_IOPS_MKDIR_IDMAP, 1,
			    [iops->mkdir() takes struct mnt_idmap*])
		],[
			AC_MSG_RESULT(no)

			dnl #
			dnl # 5.12 API change
			dnl # The struct user_namespace arg was added as the first argument to
			dnl # mkdir() of the iops structure.
			dnl #
			AC_MSG_CHECKING([whether iops->mkdir() takes struct user_namespace*])
			ZFS_LINUX_TEST_RESULT([mkdir_user_namespace], [
				AC_MSG_RESULT(yes)
				AC_DEFINE(HAVE_IOPS_MKDIR_USERNS, 1,
				    [iops->mkdir() takes struct user_namespace*])
			],[
				AC_MSG_RESULT(no)
			])
		])
	])
])
