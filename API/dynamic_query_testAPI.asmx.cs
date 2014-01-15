using System;
using System.Data;
using System.Web.Services;
using System.Net;
using System.IO;
using System.Text;

namespace Test.Web.Services
{
	/// <summary>
	/// Test Code
	/// </summary>
	[WebService(Namespace = "http://")]
	// [System.Web.Script.Services.ScriptService]
	public class Test : System.Web.Services.WebService
	{
		#region
		/// <summary>
		/// Test
		/// </summary>
		/// <param name="test_id"></param>
		/// <param name="test_name"></param>
		/// <param name="active"></param>
		/// <param name="PageIndex"></param>
		/// <param name="ListCountPerPage"></param>
		/// <returns></returns>
		[WebMethod(Description = "Test")]
		public DataTable TestGetMatch(string test_id, string test_name, bool active, int PageIndex, int ListCountPerPage)
		{
			return (new Test.Biz.TestBiz()).TestGetMatch(test_id, test_name, active, PageIndex, ListCountPerPage);
		}

		#endregion
	}
}
