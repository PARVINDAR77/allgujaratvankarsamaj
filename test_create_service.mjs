// Test creating a new service via admin API
async function testCreate() {
  const res = await fetch('http://localhost:3000/api/v1/admin/samaj-services', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      title: 'ટેસ્ટ સર્વિસ - Test Service',
      category: 'Test',
      icon: '✅',
      description: 'Test service to verify the fix works.',
      isActive: true,
    }),
  });
  console.log('Status:', res.status);
  const data = await res.json();
  console.log('Response:', JSON.stringify(data, null, 2));
  
  if (res.ok) {
    console.log('\n✅ SUCCESS! New services can now be created properly!');
    // Clean up - delete the test service
    const del = await fetch(`http://localhost:3000/api/v1/admin/samaj-services/${data.id}`, { method: 'DELETE' });
    console.log('Cleanup delete status:', del.status);
  } else {
    console.log('\n❌ Still failing. Error details above.');
  }
}

testCreate().catch(console.error);
