export const formatDate = (dateString: string): string => {
  return new Date(dateString).toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  });
};

export const getBrowserFromUserAgent = (userAgent: string): string => {
  if (userAgent.includes('Chrome')) return 'Chrome';
  if (userAgent.includes('Firefox')) return 'Firefox';
  if (userAgent.includes('Safari')) return 'Safari';
  if (userAgent.includes('Edge')) return 'Edge';
  if (userAgent.includes('Opera')) return 'Opera';
  if (userAgent.includes('Brave')) return 'Brave';
  return 'Unknown';
};

export const getOSFromUserAgent = (userAgent: string): string => {
  if (userAgent.includes('Windows NT 10.0')) return 'Windows 10';
  if (userAgent.includes('Windows NT')) return 'Windows';
  if (userAgent.includes('Mac OS X')) return 'macOS';
  if (userAgent.includes('Linux')) return 'Linux';
  if (userAgent.includes('Android')) return 'Android';
  if (userAgent.includes('iPhone') || userAgent.includes('iPad')) return 'iOS';
  return 'Unknown';
};

export const getActionColor = (action: string): string => {
  const colorMap: Record<string, string> = {
    login: 'bg-green-100 text-green-800',
    logout: 'bg-gray-100 text-gray-800', 
    create: 'bg-blue-100 text-blue-800',
    update: 'bg-yellow-100 text-yellow-800',
    delete: 'bg-red-100 text-red-800',
    view: 'bg-purple-100 text-purple-800',
    login_failed: 'bg-red-100 text-red-800'
  };

  for (const [key, color] of Object.entries(colorMap)) {
    if (action.toLowerCase().includes(key)) {
      return color;
    }
  }
  
  return 'bg-gray-100 text-gray-800';
};

export const getRoleColor = (role: string): string => {
  const colors: Record<string, string> = {
    super_admin: 'bg-red-100 text-red-800',
    admin: 'bg-orange-100 text-orange-800',
    farmer: 'bg-blue-100 text-blue-800'
  };
  
  return colors[role] || 'bg-gray-100 text-gray-800';
};