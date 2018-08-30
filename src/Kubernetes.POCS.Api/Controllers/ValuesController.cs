using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace Kubernetes.POCS.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ValuesController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public ValuesController(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        // GET api/values
        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
        {
            var hangfireConnection = _configuration.GetSection("connectionStrings:hangfireDb").Value;
            var elasticsearchConnection = _configuration.GetSection("connectionStrings:elasticsearch").Value;

            var keycloakUri = _configuration.GetSection("keycloakUri").Value;
            var clientId = _configuration.GetSection("clientId").Value;
            var clientSecret = _configuration.GetSection("clientSecret").Value;

            var values = new List<KeyValuePair<string, string>>()
            {
                new KeyValuePair<string, string>("hangfireConnection: ", hangfireConnection),
                new KeyValuePair<string, string>("elasticsearchConnection: ", elasticsearchConnection),
                new KeyValuePair<string, string>("keycloakUri: ", keycloakUri),
                new KeyValuePair<string, string>("clientId: ", clientId),
                new KeyValuePair<string, string>("clientSecret: ", clientSecret)
            };

            return Ok(values);
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public ActionResult<string> Get(int id)
        {
            return "value";
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
